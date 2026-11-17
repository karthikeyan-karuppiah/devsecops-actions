# Changelog

## [1.2.1](https://github.com/karthikeyan-karuppiah/devsecops-actions/compare/v1.2.0...v1.2.1) (2026-11-17)


### Bug Fixes

* **ci:** resolve release tag refspec and support local workflow_run testing ([42786ef](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/42786efdfe499118bf5d833fe9e73fd970c3517b))

## [1.2.0](https://github.com/karthikeyan-karuppiah/devsecops-actions/compare/v1.1.0...v1.2.0) (2026-11-16)


### Features

* add integration test fixtures, harden actions, and complete documentation ([95378f7](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/95378f711984e6ee00e1bf769b74392c5c5eb6ef))


### Bug Fixes

* **ci:** fix mangled actionlint module path in go install ([e906a89](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/e906a89efd305292997ca2362eda966a2ddfcb77))

## [1.1.0](https://github.com/karthikeyan-karuppiah/devsecops-actions/compare/v1.0.0...v1.1.0) (2026-11-16)


### Features

* **ci:** add automated release management and local action validation ([955b8a3](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/955b8a3c8356e3e7d118b2c186bb77cd76815da1))
* **ci:** configure actionlint ignore for lockfile paths and enable automated releases ([b22c8bc](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/b22c8bc4e05610018d5dbf6e0d0b0e69deb540ee))


### Bug Fixes

* **ci:** download actionlint binary before running lint check ([80b8c54](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/80b8c54259352774005a2ae0dbca983218a18109))
* **ci:** install actionlint via go install with checksum verification ([7da9da9](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/7da9da9fb58515995654c632edaf019a2218469b))
* **ci:** invoke actionlint cli with -ignore flag for lockfile paths ([6a07448](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/6a074487218cae0befd7d55e42e4ad603140c3d3))
* **ci:** invoke actionlint from GOPATH/bin ([7787a8b](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/7787a8b2e2dc9c65c9d74e8d9c98af8a9a089a05))
* **ci:** replace $ with . in local action paths ([9865cdf](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/9865cdf5d77ecc5f1c208e8477d30724a682a7ca))
* **ci:** restore full actionlint module path in go install ([37c7294](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/37c72942f44fa40196ffc241b394533232a0e26f))
* **ci:** update action paths ([0a341d3](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/0a341d3e4337b19b31e9db594224a262bf8717a1))
* **ci:** update GitHub Actions workflow lockfile ([9b595cd](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/9b595cdaefeee89dbb66e450a64fc2815e94029b))
* **ci:** use character class for literal dollar sign in actionlint config ([549f265](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/549f265c53fa42b041a9951c920bb9e60663d240))

## 1.0.0 (2026-11-16)


### Features

* initial release of shared composite actions ([56b7c6a](https://github.com/karthikeyan-karuppiah/devsecops-actions/commit/56b7c6a29ab24bd67a3f03d41cb07abbbc956eca))
