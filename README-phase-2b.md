0. The goal of phase 2b is to perform benchmarking/scalability tests of sample three-tier lakehouse solution.

1. In main.tf, change machine_type at:

```
module "dataproc" {
  depends_on   = [module.vpc]
  source       = "github.com/bdg-tbd/tbd-workshop-1.git?ref=v1.0.36/modules/dataproc"
  project_name = var.project_name
  region       = var.region
  subnet       = module.vpc.subnets[local.notebook_subnet_id].id
  machine_type = "e2-standard-2"
}
```


and subsititute "e2-standard-2" with "e2-standard-4".

2. If needed request to increase cpu quotas (e.g. to 30 CPUs): 
https://console.cloud.google.com/apis/api/compute.googleapis.com/quotas?project=tbd-2023z-9918

![img.png](doc/figures/cpus_quota_all_regions.png)

![img.png](doc/figures/cpus_quota_europe_central.png)

3. Using tbd-tpc-di notebook perform dbt run with different number of executors, i.e., 1, 2, and 5, by changing:
```
 "spark.executor.instances": "2"
```

in profiles.yml.

4. In the notebook, collect console output from dbt run, then parse it and retrieve total execution time and execution times of processing each model. Save the results from each number of executors. 

5. Analyze the performance and scalability of execution times of each model. Visualize and discucss the final results.

Całkowity czas wykonania dla różnych wartości parametru *spark.executor.instances*:

- 1: 116 min 21 s
- 2: 67 min 25 s
- 4: 74 min 10 s

![img.png](doc/figures/Total_Time.png) 

Zadanie zajęło najmniej czasu w przypadku wartości parametru *spark.executor.instances* = 2. Przy zmianie z 1 na 2 executorów, czas wykonania znacznie się skrócił o około 40%. Jednak gdy liczba executorów wzrosła z 2 do 4, czas wykonania nieznacznie wzrósł, co sugeruje, że dodatkowe executory nie były efektywnie wykorzystywane, prawdopodobnie z powodu rywalizacji o zasoby.

Wykres poniżej przedstawia czas tworzenia kolejnych tabel w przypadku różnej liczby executorów. 

![img.png](doc/figures/Execution_Time.png) 

Dla tabel z dłuższymi czasami tworzenia (np. demo_silver.daily_market, demo_silver.trades_history), redukcja całkowitego czasu wykonania jest znacząca przy przejściu z 1 do 2 executorów. Jednak po zwiększeniu liczby executorów do 4 dla dużych tabel nie widać poprawy, co może sugerować, że osiągnięto optymalną wydajność przy 2 executorach. Dodanie większej liczby executorów po pewnym momencie nie zawsze powoduje zwiększenie wydajności. Warto monitorować zasoby, aby upewnić się, że dodanie większej liczby executorów rzeczywiście wykorzystuje dostępne zasoby.
   
