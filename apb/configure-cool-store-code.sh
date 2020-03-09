#!/bin/bash 

cd /projects/labs/catalog-spring-boot
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/catalog-spring-boot/pom.xml

cd /projects/labs/catalog-spring-boot/src/main/java/com/redhat/cloudnative/catalog/
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/catalog-spring-boot/src/main/java/com/redhat/cloudnative/catalog/CatalogController.java
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/catalog-spring-boot/src/main/java/com/redhat/cloudnative/catalog/Product.java
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/catalog-spring-boot/src/main/java/com/redhat/cloudnative/catalog/ProductRepository.java

cd /projects/labs/catalog-spring-boot/src/main/resources/static/
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/catalog-spring-boot/src/main/resources/static/index.html
curl -OL https://github.com/tosin2013/cloud-native-labs/blob/master/solutions/all/catalog-spring-boot/src/main/resources/static/spring-boot.png

cd  /projects/labs/inventory-thorntail/
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/inventory-thorntail/pom.xml

cd /projects/labs/inventory-thorntail/src/main/java/com/redhat/cloudnative/inventory
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/inventory-thorntail/src/main/java/com/redhat/cloudnative/inventory/Inventory.java
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/inventory-thorntail/src/main/java/com/redhat/cloudnative/inventory/InventoryApplication.java
curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/inventory-thorntail/src/main/java/com/redhat/cloudnative/inventory/InventoryResource.java

cd /projects/labs/gateway-vertx/src/main/java/com/redhat/cloudnative/gateway
curl -OL  https://raw.githubusercontent.com/tosin2013/cloud-native-labs/master/solutions/all/gateway-vertx/src/main/java/com/redhat/cloudnative/gateway/GatewayVerticle.java