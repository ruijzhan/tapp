REGISTRY := tkestack
TAG := v1.1.1
SCRIPT_PATH := hack

.PHONY: all clean build test verify verify-gofmt format deploy-image release release.multiarch manifests crd-install crd-uninstall

all: verify-gofmt build test

clean:
	rm -rf bin/ _output/ go .version-defs

build:
	$(SCRIPT_PATH)/build.sh

include build/lib/common.mk
include build/lib/image.mk

test:
	TESTFLAGS=$(TFLAGS) $(SCRIPT_PATH)/test-go.sh

verify:
	$(SCRIPT_PATH)/verify-all.sh

verify-gofmt:
	$(SCRIPT_PATH)/verify-gofmt.sh

format:
	$(SCRIPT_PATH)/format.sh

deploy-image:
	$(SCRIPT_PATH)/build-image.sh $(REGISTRY)/tapp-controller:$(TAG)
	$(SCRIPT_PATH)/push-image.sh $(REGISTRY)/tapp-controller:$(TAG)

release: deploy-image

release.multiarch:
	@$(MAKE) image.manifest.push.multiarch BINS="tapp-controller"

#  vim: set ts=2 sw=2 tw=0 noet :

manifests:
	controller-gen paths=./pkg/apis/... crd:maxDescLen=10 output:artifacts:config=config/crd/bases
	find ./config/crd/bases/ -type f -exec sed -i'' 's/tappcontroller.k8s.io/apps.tkestack.io/g' {} \;

crd-install:
	kubectl apply -f config/crd/bases

crd-uninstall:
	kubectl delete -f config/crd/bases
