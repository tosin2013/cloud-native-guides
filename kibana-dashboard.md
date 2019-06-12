## Navigating the Kibana Dashboard

Before we dive into using the Kibana dashboard. We must first review what is the ELK stack.

ELK stands for  

* **ElasticSearch** - Is used for deep search and data analytics.  It is an open source distributed NOSQL database, built in Java and based on Apache Lucene. Lucene takes care of storing disk data, indexing, and document scanning while ElasticSearch keeps document updates, APIs and document distribution between ElasticSearch instances in the same cluster.   
* **Logstash** - Is used for centralized logging, log enrichment and parsing. It is a ETL (Extract, Transfer, Load) tool that transforms and storages logs within ElasticSearch.  
* **Kibana** - Is a web-based tool through which ElasticSearch databases visualize and analyze stored data.  

What is Fluentd?  

**Fluentd** is a popular opensource data collector that is setup on the openshift luster to tail container logs files, filter and transform the log data and deliver it to the ElasticSEarch cluster. From there the logs will be indexed and stored.  

Log Analysis  

**Log Analysis** is a very important topic to consider when developing an application. There are different reasons for this one reason that can be explored is performance. Performance issues can damage the brand of the business and in some cases translate into a direct revenue loss. Security is another reason log analysis is very important companies cannot afford to be compromised. This and complying with regulatory standards can result in hefty fines and damage a business just as much as a performance issue.  

When looking at log management and analysis solutions we should consider the following key capabilities while developing an app.  

* **Aggregation** - Does my system have the ability to collect and ship logs from multiple data sources?
* **Processing** - Does my system have the ability to transfrom log messages into meaningful data for easier analysis. 
* **Storage** - Does my system have the ability to store data for extended time periods to allow for monitoring, thrend analysis and security use cases?
* **Analysis** -Does my system have the ability to dissect the data by querying it and creating visualizations and dashboards on top of it. 

Log Stash Processing  

Logstash processing take place in three stages  

* **Input**- The input stage is how Log stash receives the data. An input plugin cloud be a file so that Logostash reads events from a file; and HTTP endpoint; a relational  database, etc.  
* **Filter** - THe stage is about how Logstash processes the events recieved from the input stage plugins. Here CSV, XML or JSON can be parsed. Data enrichment operations can be performed such as look up an IP address and resolving is geographical location.  
* **Output** - And output plugin is where we send the processed events to. These can be referred to as stashes. These place can be na databases, a file, and ElasticSearch instance and so on.  

Sample logstash config

~~~shell

input {  
    file {
        path => ["/var/log/myapp/*.log"]
    }
}

filter {  
    // Collect or process some data (e.g. 'time') as timestamp and
    // store them into @timestamp data.
    // That data will later be used by Kibana.

    date {
        match => [ "time" ]
    }

     // Adds geolocation data based on the IP address.
    geoip {
        source => "ip"
    }
}

output {  
    elasticsearch {
       hosts => ["localhost:9200"]
    }
    stdout { codec => rubydebug }
}

input {  
    file {
        path => ["/var/log/myapp/*.log"]
    }
}

filter {  
    // Collect or process some data (e.g. 'time') as timestamp and
    // store them into @timestamp data.
    // That data will later be used by Kibana.

    date {
        match => [ "time" ]
    }

     // Adds geolocation data based on the IP address.
    geoip {
        source => "ip"
    }
}

output {  
    elasticsearch {
       hosts => ["localhost:9200"]
    }
    stdout { codec => rubydebug }
}

~~~

**More Information** 

[Aggregating Container Logs](https://docs.openshift.com/container-platform/3.11/install_config/aggregate_logging.html)  
[Aggregate Logging Sizing Guidelines](https://docs.openshift.com/container-platform/3.11/install_config/aggregate_logging_sizing.html)  

## Exercises  

#### Navigate to Kibana dashboard  

1. Under overview click on gateway.  
2. Click on deployment number Example: #1 latest.  
3. Click on pod name example: gateway-1-wxyz  
4. Click on logs  
5. Click on  View Archive  
![View Archive]({% image_path kibana-view-archive.png %}){:width="900px"}  
6.  You may have to  relogin to the dashboard  using your OpenShift username and password.  

#### Reviewing  default filter  

![Default Filter on login]({% image_path kibana-default-filter-on-login.png %}){:width="900px"}  

As seen in the picture above when we click on the view-archive in the above step it filters the result by pod name and the namespace.  

* `kubernetes.pod_name:"gateway-5-bbdk4` is filtering on `gateway-5-bbdk4` by pod name  
* `kubernetes.namespace_name:"coolstore-1` is filtering on `coolstore-1` by namespace or project.  

#### Filter by namespace  

Now let use filter based on  namespace `kubernetes.namespace_name:"coolstore-XX"`  
Lets update the time span  

1. Click on `Last 1w` in top right had corner.  
2. Click on `Quick` click on `Last 30 minutes`  
3. Review the 30 minutes of log data. How many hits are seen.  

Lets turn on Auto-refresh  

1. Click on `Last 30 minutes` in top right had corner.  
2. Click on `Auto-refresh`.  
3. Change Refresh interval to  `10 seconds`.  
4. Review the 30 minutes of log data. Notice how the number of hits change when there is activeity on the system.  
optional open make open the coolstore and navigate the site. http://web-coolstore-1.apps.atlanta-2c4e.openshiftworkshop.com/

#### Filter by namespace log level  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND level:err)

(kubernetes.namespace_name:"coolstore-XX" AND level:info)
~~~

#### Save error filter  

1. search using the following query `(kubernetes.namespace_name:"coolstore-XX" AND level:err)`
2. click on Save
3. Save search name as `Namespace Errors`

#### Create Visualization  

1. Click on `Visualize`  
2. Click on `Create a visualization`  
3. Click on `Metric`  
4. Click  on `Namespace Errors` under the `Or, From a Saved Search`  menu.  
5. Click on Save  
6. Save Visualization as `Namespace Error Count`  


#### Create Dashboard  

1. Click on `Dashboard`  
2. Click on `Create a dashboard`  
3. Click on `Add`  
4. Click on the `Namespace Error Count` under Visualization  
5. click on save  
6. Save dashboard as `Main Dashboard`  


#### Other Filtering options  

>Below are other filters you can play with.  There are many options that can be used. Under the selected fields you can modify the table that is shown in your dashboard by clicking on a selected field.  

![Selected Fields]({% image_path kibana-selected-fields.png %}){:width="75%"}{:height="75%"}  

**Experiment with adding and removing selected fields while you are filtering the logs.**  

Filter by namespace and POD name  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND kubernetes.pod_name:vertx)  
~~~

Filter by namespace and container name  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND kubernetes.container_name:vertx)
~~~

Filter by namespace and container name  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND kubernetes.labels.app:catalog)  
~~~

Filter by namespace and deployment  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND  kubernetes.labels.deploymentconfig:gateway)  
~~~

Chain a query  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND kubernetes.labels.app:catalog) OR(kubernetes.namespace_name:"coolstore-XX" AND kubernetes.labels.app:gateway) OR(kubernetes.namespace_name:"coolstore-XX"  AND kubernetes.labels.app:inventory) OR(kubernetes.namespace_name:"coolstore-XX"  AND kubernetes.labels.app:web)
~~~

#### Get status code of Post via vert.x using regex  

We will not create a dashboard the collects the status of querying the product api thorough the gateway.  

Filter the gateway using the filter below  

~~~shell
(kubernetes.namespace_name:"coolstore-XX" AND kubernetes.labels.app:gateway  AND message:*status code*)
~~~

Generate some messages  

~~~shell
ENDPOINT=http://$(oc get route | grep gateway | awk '{print $2}')
echo $ENDPOINT/api/products
for i in {1..20}; do
  curl -s -k $ENDPOINT/api/products
  sleep 1s
done
~~~

#### Create Visualization  

1. Click on `Visualize`  
2. Click on `Create a visualization`  
3. Click on `Metric`  
4. Click  on `Namespace Errors` under the `Or, From a Saved Search`  menu.  
5. Click on Save  
6. Save Visualization as `Vert.x Status Code`  


#### Create Dashboard  

1. Click on `Dashboard`  
2. Click on `Create a dashboard`  
3. Click on `Add`  
4. Click on the `Vert.x Status Code` under Visualization  
5. click on save  
6. Save dashboard as `Main Dashboard`  

#### Fluentd Java Example  

Below are example steps of configuring a java application to use fluentd.  
[Fluentd Java](https://docs.fluentd.org/language-bindings/java)  

Install the tdagent RPM  
Modify the config file then restart your td-agent service  

~~~xml
<source>
@type forward
port 24224
</source>
<match fluentd.test.>
@type stdout
</match>
~~~

Update your pom.xml with the appropriate dependency information  

~~~xml
<dependencies>
...
<dependency>
    <groupId>org.fluentd</groupId>
    <artifactId>fluent-logger</artifactId>
    <version>${logger.version}</version>
</dependency>
...
</dependencies>
~~~

Add the following to your application  

~~~java
import java.util.HashMap;
import java.util.Map;
import org.fluentd.logger.FluentLogger;  // Add to your  application

public class Main {
    private static FluentLogger LOG = FluentLogger.getLogger("fluentd.test"); // Add to your  application

    public void doApplicationLogic() {
        // ...
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("from", "userA");
        data.put("to", "userB");
        LOG.log("follow", data); // Add to your  application
        // ...
    }
}
~~~

Once your app is running logs will report to td-agent.log  

~~~shell
tail  -f /var/log/td-agent/td-agent.log 
~~~

Well done and congratulations for completing all the labs.
