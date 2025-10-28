
<a name="icm-web-0.17.0-alpha"></a>
## [icm-web-0.17.0-alpha](https://github.com/intershop/helm-charts/compare/icm-web-0.14.5...icm-web-0.17.0-alpha)

> 2025-10-28

### Features

* **icm:** label unification ([#1106](https://github.com/intershop/helm-charts/issues/1106))


<a name="icm-web-0.14.5"></a>
## [icm-web-0.14.5](https://github.com/intershop/helm-charts/compare/icm-web-0.14.4...icm-web-0.14.5)

> 2025-08-21

### Bug Fixes

* **icm:** consume newest webadapter ([#1070](https://github.com/intershop/helm-charts/issues/1070))


<a name="icm-web-0.14.4"></a>
## [icm-web-0.14.4](https://github.com/intershop/helm-charts/compare/icm-web-0.14.3...icm-web-0.14.4)

> 2025-07-07


<a name="icm-web-0.14.3"></a>
## [icm-web-0.14.3](https://github.com/intershop/helm-charts/compare/icm-web-0.14.2...icm-web-0.14.3)

> 2025-03-04


<a name="icm-web-0.14.2"></a>
## [icm-web-0.14.2](https://github.com/intershop/helm-charts/compare/icm-web-0.14.1...icm-web-0.14.2)

> 2025-03-04

### Bug Fixes

* **icm:** wrong context ([#928](https://github.com/intershop/helm-charts/issues/928))


<a name="icm-web-0.14.1"></a>
## [icm-web-0.14.1](https://github.com/intershop/helm-charts/compare/icm-web-0.14.0...icm-web-0.14.1)

> 2025-03-04

### Bug Fixes

* some optimizations to configMapMounts ([#928](https://github.com/intershop/helm-charts/issues/928))


<a name="icm-web-0.14.0"></a>
## [icm-web-0.14.0](https://github.com/intershop/helm-charts/compare/icm-web-0.13.3...icm-web-0.14.0)

> 2025-03-03

### Features

* configuration of volumemounts for existing configmaps ([#921](https://github.com/intershop/helm-charts/issues/921))


<a name="icm-web-0.13.3"></a>
## [icm-web-0.13.3](https://github.com/intershop/helm-charts/compare/icm-web-0.13.2...icm-web-0.13.3)

> 2025-02-28

### Bug Fixes

* **icm:** disable integrated NR agent log forwding ([#915](https://github.com/intershop/helm-charts/issues/915))


<a name="icm-web-0.13.2"></a>
## [icm-web-0.13.2](https://github.com/intershop/helm-charts/compare/icm-web-0.13.1...icm-web-0.13.2)

> 2024-12-12

### Bug Fixes

* update WAA to 5.1.0 and adapt resource defaults ([#831](https://github.com/intershop/helm-charts/issues/831))


<a name="icm-web-0.13.1"></a>
## [icm-web-0.13.1](https://github.com/intershop/helm-charts/compare/icm-web-0.13.0...icm-web-0.13.1)

> 2024-11-26


<a name="icm-web-0.13.0"></a>
## [icm-web-0.13.0](https://github.com/intershop/helm-charts/compare/icm-web-0.12.1...icm-web-0.13.0)

> 2024-11-25


<a name="icm-web-0.12.1"></a>
## [icm-web-0.12.1](https://github.com/intershop/helm-charts/compare/icm-web-0.12.0...icm-web-0.12.1)

> 2024-11-22

### Bug Fixes

* fix ingress annotation conflict in icm-web chart ([#834](https://github.com/intershop/helm-charts/issues/834))


<a name="icm-web-0.12.0"></a>
## [icm-web-0.12.0](https://github.com/intershop/helm-charts/compare/icm-web-0.11.0...icm-web-0.12.0)

> 2024-08-12

### Features

* **icm:** WAA and WA doesn't share pagecache directory in case of emptydir is configured and New Relic ([#785](https://github.com/intershop/helm-charts/issues/785), [#786](https://github.com/intershop/helm-charts/issues/786))
* **icm:** allow shutdown via replicas=0 definition ([#787](https://github.com/intershop/helm-charts/issues/787))


<a name="icm-web-0.11.0"></a>
## [icm-web-0.11.0](https://github.com/intershop/helm-charts/compare/icm-web-0.10.0...icm-web-0.11.0)

> 2024-07-24

### Features

* **icm:** Configurable access to internal WA endpoints


<a name="icm-web-0.10.0"></a>
## [icm-web-0.10.0](https://github.com/intershop/helm-charts/compare/icm-web-0.9.1...icm-web-0.10.0)

> 2024-07-09

### Features

* **icm:** Try to schedule WA pods evenly over different nodes ([#729](https://github.com/intershop/helm-charts/issues/729))


<a name="icm-web-0.9.1"></a>
## [icm-web-0.9.1](https://github.com/intershop/helm-charts/compare/icm-web-0.9.0...icm-web-0.9.1)

> 2024-06-10

### Bug Fixes

* Support graceful container shutdown of WebAdapterAgent
* Support graceful container shutdown of WebAdapter


<a name="icm-web-0.9.0"></a>
## [icm-web-0.9.0](https://github.com/intershop/helm-charts/compare/icm-web-0.8.0...icm-web-0.9.0)

> 2024-04-22

### Features

* ICM-WA probes
* support secrets store csi v1  ([#384](https://github.com/intershop/helm-charts/issues/384)) ([#400](https://github.com/intershop/helm-charts/issues/400))
* writes WA-logs to external storage ([#382](https://github.com/intershop/helm-charts/issues/382)) ([#383](https://github.com/intershop/helm-charts/issues/383))


<a name="icm-web-0.8.0"></a>
## [icm-web-0.8.0](https://github.com/intershop/helm-charts/compare/icm-web-0.7.6...icm-web-0.8.0)

> 2023-08-23

### Features

* writes WA-logs to external storage ([#382](https://github.com/intershop/helm-charts/issues/382)) ([#383](https://github.com/intershop/helm-charts/issues/383))


<a name="icm-web-0.7.6"></a>
## [icm-web-0.7.6](https://github.com/intershop/helm-charts/compare/icm-web-0.7.5...icm-web-0.7.6)

> 2023-07-28


<a name="icm-web-0.7.5"></a>
## [icm-web-0.7.5](https://github.com/intershop/helm-charts/compare/icm-web-0.7.4...icm-web-0.7.5)

> 2023-06-15

### Bug Fixes

* use securityGroup configuration for azure file ([#310](https://github.com/intershop/helm-charts/issues/310))


<a name="icm-web-0.7.4"></a>
## [icm-web-0.7.4](https://github.com/intershop/helm-charts/compare/icm-web-0.7.3...icm-web-0.7.4)

> 2023-04-28


<a name="icm-web-0.7.3"></a>
## [icm-web-0.7.3](https://github.com/intershop/helm-charts/compare/icm-web-0.7.2...icm-web-0.7.3)

> 2023-04-03


<a name="icm-web-0.7.2"></a>
## [icm-web-0.7.2](https://github.com/intershop/helm-charts/compare/icm-web-0.7.1...icm-web-0.7.2)

> 2023-03-30


<a name="icm-web-0.7.1"></a>
## [icm-web-0.7.1](https://github.com/intershop/helm-charts/compare/icm-web-0.7.0...icm-web-0.7.1)

> 2023-03-28


<a name="icm-web-0.7.0"></a>
## [icm-web-0.7.0](https://github.com/intershop/helm-charts/compare/icm-web-0.6.0...icm-web-0.7.0)

> 2023-03-24


<a name="icm-web-0.6.0"></a>
## [icm-web-0.6.0](https://github.com/intershop/helm-charts/compare/icm-web-0.5.0...icm-web-0.6.0)

> 2023-03-06


<a name="icm-web-0.5.0"></a>
## [icm-web-0.5.0](https://github.com/intershop/helm-charts/compare/icm-web-0.4.0...icm-web-0.5.0)

> 2022-12-15


<a name="icm-web-0.4.0"></a>
## [icm-web-0.4.0](https://github.com/intershop/helm-charts/compare/icm-web-0.2.5...icm-web-0.4.0)

> 2022-10-20


<a name="icm-web-0.2.5"></a>
## [icm-web-0.2.5](https://github.com/intershop/helm-charts/compare/icm-web-0.2.4...icm-web-0.2.5)

> 2022-09-08

### Bug Fixes

* there is no resource enablement


<a name="icm-web-0.2.4"></a>
## [icm-web-0.2.4](https://github.com/intershop/helm-charts/compare/icm-web-0.2.3...icm-web-0.2.4)

> 2022-09-02


<a name="icm-web-0.2.3"></a>
## [icm-web-0.2.3](https://github.com/intershop/helm-charts/compare/icm-web-0.2.2...icm-web-0.2.3)

> 2022-07-22

### Features

* cluster persistence owner shall be 150 (intershop) ([#116](https://github.com/intershop/helm-charts/issues/116))


<a name="icm-web-0.2.2"></a>
## [icm-web-0.2.2](https://github.com/intershop/helm-charts/compare/icm-web-0.2.1...icm-web-0.2.2)

> 2022-07-21

### Bug Fixes

* fix nfs persistence definition ([#112](https://github.com/intershop/helm-charts/issues/112))
* fix lint test for icm-charts ([#99](https://github.com/intershop/helm-charts/issues/99))


<a name="icm-web-0.2.1"></a>
## [icm-web-0.2.1](https://github.com/intershop/helm-charts/compare/icm-web-0.1.35...icm-web-0.2.1)

> 2022-07-06

### Bug Fixes

* fix several lint issues ([#99](https://github.com/intershop/helm-charts/issues/99))
* fix local lint test for icm-web ([#99](https://github.com/intershop/helm-charts/issues/99))
* use PageCache PVC ([#87](https://github.com/intershop/helm-charts/issues/87)) ([#88](https://github.com/intershop/helm-charts/issues/88))
* storageClassName shall be azurefiles ([#83](https://github.com/intershop/helm-charts/issues/83)) ([#84](https://github.com/intershop/helm-charts/issues/84))

### Features

* set release versions ([#91](https://github.com/intershop/helm-charts/issues/91))
* add configurations to helm chart ([#77](https://github.com/intershop/helm-charts/issues/77)) ([#78](https://github.com/intershop/helm-charts/issues/78))


<a name="icm-web-0.1.35"></a>
## [icm-web-0.1.35](https://github.com/intershop/helm-charts/compare/icm-web-0.1.34...icm-web-0.1.35)

> 2022-07-04


<a name="icm-web-0.1.34"></a>
## [icm-web-0.1.34](https://github.com/intershop/helm-charts/compare/icm-web-0.1.33...icm-web-0.1.34)

> 2022-06-22


<a name="icm-web-0.1.33"></a>
## [icm-web-0.1.33](https://github.com/intershop/helm-charts/compare/icm-web-0.1.32...icm-web-0.1.33)

> 2022-06-22


<a name="icm-web-0.1.32"></a>
## [icm-web-0.1.32](https://github.com/intershop/helm-charts/compare/icm-web-0.1.31...icm-web-0.1.32)

> 2022-06-10


<a name="icm-web-0.1.31"></a>
## [icm-web-0.1.31](https://github.com/intershop/helm-charts/compare/icm-web-0.1.30...icm-web-0.1.31)

> 2022-05-10


<a name="icm-web-0.1.30"></a>
## icm-web-0.1.30

> 2022-05-04

### Features

* Add umbrella chart icm ([#11](https://github.com/intershop/helm-charts/issues/11)) ([#13](https://github.com/intershop/helm-charts/issues/13))
* Add icm related helm charts to public helm chart repo ([#10](https://github.com/intershop/helm-charts/issues/10))

