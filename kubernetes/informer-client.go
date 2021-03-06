package main

import (
	"fmt"
	"k8s.io/api/core/v1"
	"k8s.io/client-go/informers"
	coreinformers "k8s.io/client-go/informers/core/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
	"os"
	"path/filepath"
	"time"
)

type PodController struct {
	informerFactory informers.SharedInformerFactory
	podInformer     coreinformers.PodInformer
}

func (c *PodController) Run(stopCh chan struct{}) error {
	c.informerFactory.Start(stopCh)
	if !cache.WaitForCacheSync(stopCh, c.podInformer.Informer().HasSynced) {
		return fmt.Errorf("failed to sync cache")
	}
	return nil
}

func NewPodController(informerFactory informers.SharedInformerFactory) *PodController {
	podInformer := informerFactory.Core().V1().Pods()

	c := &PodController{
		informerFactory: informerFactory,
		podInformer:     podInformer,
	}
	podInformer.Informer().AddEventHandler(
		cache.ResourceEventHandlerFuncs{
			AddFunc: c.podAdd,
			UpdateFunc: c.podUpdate,
			DeleteFunc: c.podDelete,
		},
	)
	return c
}

func (c *PodController) podAdd(obj interface{}) {
	pod := obj.(*v1.Pod)
	fmt.Printf("Pod created: %s/%s\n", pod.Namespace, pod.Name)
}

func (c *PodController) podUpdate(old, new interface{}) {
	oldPod := old.(*v1.Pod)
	newPod := new.(*v1.Pod)
	fmt.Printf("Pod updated: %s/%s %s\n", oldPod.Namespace, oldPod.Name, newPod.Status.Phase)
}

func (c *PodController) podDelete(obj interface{}) {
	pod := obj.(*v1.Pod)
	fmt.Printf("Pod deleted: %s/%s\n", pod.Namespace, pod.Name)
}

func main() {

	config, err := rest.InClusterConfig()
	if err != nil {
		kubeconfig := filepath.Join(os.Getenv("HOME"), ".kube", "config")
		if envvar := os.Getenv("KUBECONFIG"); len(envvar) > 0 {
			kubeconfig = envvar
		}
		config, err = clientcmd.BuildConfigFromFlags("", kubeconfig)
		if err != nil {
			fmt.Printf("The kubeconfig cannot be loaded: %v\n", err)
			os.Exit(1)
		}
	}

	clientset, err := kubernetes.NewForConfig(config)

	factory := informers.NewSharedInformerFactory(clientset, time.Hour*24)
	controller := NewPodController(factory)
	stop := make(chan struct{})
	defer close(stop)
	err = controller.Run(stop)
	if err != nil {
		fmt.Println(err)
	}
	select {}
}
