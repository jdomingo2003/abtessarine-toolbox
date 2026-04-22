# abtessarine_Toolbox

**Version:** 1.0.0 (SoftwareX Submission)
**Date:** 11-Apr-2026

## Overview
The **abtessarine_Toolbox** is a high-performance, object-oriented MATLAB library designed for the analysis and manipulation of commutative hypercomplex algebras. 

This toolbox provides a robust computational framework for **$\alpha\beta$-tessarines** ($\alpha \in \mathbb{R}\setminus\{0\}, \beta > 0$), a 4-dimensional hypercomplex algebra that encompasses generalized Segre's quaternions (GSQ) and elliptic quaternions as particular cases. Unlike traditional non-commutative quaternions, tessarines preserve both commutativity and associativity, which significantly enhances their compatibility with advanced linear algebra methods and spectral theory. 

Furthermore, the toolbox extends this mathematical framework to an 8-dimensional algebra known as **generalized $\alpha\beta$-tessarines** ($\mathbb{G}_{\alpha\beta}$) via the Cayley-Dickson construction ($x = x_1 + x_2 \epsilon$, where $\epsilon^2 = -1$).

## Repository Structure
To maintain a clean architecture, the toolbox is structured into core classes, root-level generators, and validation suites. The complete file structure is as follows:

* <details>
  <summary><b>@abtessarine/</b> <i>(Contains all overloaded methods and the core 4D class definition)</i></summary>

  | | | | |
  | :--- | :--- | :--- | :--- |
  | `abtessarine` | `associated` | `augmented` | `cat` |
  | `chol` | `conj_i` | `conj_j` | `conj_k` |
  | `ctranspose` | `det` | `diag` | `diff` |
  | `disp` | `eig` | `eigs` | `hermitian` |
  | `horzcat` | `inv` | `kron` | `length` |
  | `lu` | `minus` | `mldivide` | `mpower` |
  | `mrdivide` | `mtimes` | `ndims` | `norm` |
  | `permute` | `pinv` | `plus` | `power` |
  | `prod` | `qr` | `repmat` | `reshape` |
  | `size` | `sqrtm` | `squeeze` | `subsasgn` |
  | `subsref` | `sum` | `svd` | `svds` |
  | `times` | `trace` | `transpose` | `uminus` |
  | `uplus` | `vertcat` | | |

  </details>

* <details>
  <summary><b>@gabtessarine/</b> <i>(Contains all overloaded methods and the core 8D class definition)</i></summary>

  | | | | |
  | :--- | :--- | :--- | :--- |
  | `disp` | `gabtessarine` | `horzcat` | `inv` |
  | `kron` | `minus` | `mtimes` | `plus` |
  | `size` | `sqrtm` | `subsasgn` | `subsref` |
  | `times` | `uminus` | `vertcat` | |

  </details>

* `tests/` 
  * general_tests
    * `test_01...` *(Basic functionality and properties)*
    * `test_02...` *(Matrix operations and calculus)*
    * `test_03...` *(Advanced factorizations and spectral theory)*
    * `test_gabtessarine.m` *(8D algebra validation suite)*
  * individual_tests
    * tests_@abtessarine
      * test_abtessarine
    * tests_@gabtessarine
      * test_gabtessarine
    * test_abt2gabt


* `examples/` 
  * `example_1.m` *(Signal Processing: Color image compression via hypercomplex SVD)*
  * `example_2.m` *(Physics & Robotics: Solving kinematic linear systems under noise)*
  * `example_3.m` *(High-Performance Computing: Scalability benchmark vs for-loops)*
  * `example_4.m` *(Machine Learning: Fast analytical training of ELM classifiers)*
* `setabtessarine.m` *(Global topological parameter configuration)*
* `getabtessarine.m` *(Retrieves current global parameters)*
* `abteye.m`, `gabteye.m` *(Identity matrices generation)*
* `abtzeros.m`, `gabtzeros.m` *(Zero-cost memory allocation)*
* `abtones.m` *(Arrays of ones)*
* `abtrand.m`, `gabtrand.m` *(Uniformly distributed random arrays)*
* `abtrandn.m`, `gabtrandn.m` *(Normally distributed random arrays)*
* `abt2gabt.m` *(Constructs 8D Cayley-Dickson matrices from 4D arrays)*
* `abtpdm.m` *(Generates positive-definite hypercomplex matrices)*

## Comprehensive Capabilities

### 1. Matrix Generation & Environment Control
* **Environment:** `setabtessarine` (Global topological parameter configuration) and `getabtessarine` (Environment retrieval).
* **Generators:** `abtzeros` and `gabtzeros` (Zero-cost memory allocation), `abteye` and `gabteye` (Identity matrices), `abtones` (Array of ones).
* **Stochastic Arrays:** Uniform (`abtrand`, `gabtrand`) and normally distributed (`abtrandn`, `gabtrandn`) random array generators.
* **8D Assembly:** `abt2gabt` (Constructs 8D Cayley-Dickson matrices directly from 4D arrays).
* **Positive Definite Systems:** `abtpdm` (Generates strictly positive-definite hypercomplex matrices for stability in factorizations).

### 2. Advanced Matrix Factorizations & Spectral Theory
Unlike standard tools, this toolbox provides full native support for hypercomplex matrix decompositions avoiding massive `for`-loops:
* **Factorizations:** LU with partial pivoting (`lu`), Orthogonal-triangular QR decomposition (`qr`), and Cholesky factorization for Hermitian positive definite matrices (`chol`).
* **Spectral Analysis:** Full and dominant Eigenvalues/Eigenvectors computation (`eig`, `eigs`).
* **Singular Values:** Full and dominant Singular Value Decompositions (`svd`, `svds`).
* **Matrix Calculus:** Isomorphic matrix determinant (`det`), Principal matrix square root (`sqrtm`), Matrix inverse via L1 cache recycling (`inv`), Moore-Penrose pseudoinverse (`pinv`), and Matrix/Vector norms (`norm`).

### 3. Widely Linear Modeling (WLM) & Isomorphisms
* **Involutions:** Directional involutions along hypercomplex axes (`conj_i`, `conj_J`, `conj_k`).
* **Transpositions:** Parameterized Hermitian (`hermitian`), geometric (`.'`), and conjugate (`'`) transpositions.
* **Isomorphic Mappings:** Direct extraction of the associated real/complex isomorphic representation (`associated`).
* **Augmented Statistics:** Construction of the augmented covariance matrix (`augmented`) for advanced signal processing.

### 4. Zero-Overhead Operator Overloading
The classes `@abtessarine` and `@gabtessarine` overload MATLAB's internal methods, enabling natural syntax with dynamic upcasting:
* **Arithmetics & Tensors:** `+`, `-`, unary `-`, `*`, `.*`, `^`, `.^`, `kron` (Kronecker tensor product).
* **Matrix Division:** Left division/Least-squares solver (`\`) and Right division (`/`).
* **Data Manipulation:** Subscripted referencing/assignment (`X(i,j)`), array dimensions (`size`), global/dimensional sums/products (`sum`, `prod`, `diff`), and horizontal/vertical concatenations (`[X, Y]`, `[X; Y]`).

## Installation
1. Download or clone this repository to your local machine.
2. Open MATLAB and navigate to the `Home` tab.
3. Click on **Set Path** -> **Add Folder** (Select ONLY the root folder. *Do not use "Add with Subfolders"* to prevent MATLAB namespace collisions with the `@` class directories).
4. Click **Save**.

## Quick Start Guide

The global topological environment ($\alpha$ and $\beta$) must be configured before operating. The valid dimensionality of the toolbox depends on the chosen $\alpha$ parameter.

### Case 1: Operating with $\alpha > 0$ (Supports 4D and 8D Algebras)
When $\alpha$ is strictly positive, the toolbox supports the core 4D algebra and its full 8D Cayley-Dickson generalization.

    % 1. Configure the environment (e.g., alpha = 2, beta = 4)
    setabtessarine(2, 4);

    % 2. Generate massive random matrices
    X = abtrandn(100, 100);    % 4D Standard Normally Distributed Matrix
    Y = gabtrandn(100, 100);   % 8D Generalized Normally Distributed Matrix

    % 3. Transparently operate (Automatic 4D to 8D upcasting is supported)
    Z = X * Y;                
    K = kron(Y, Y);            % 8D Block expansion

    % 4. Matrix Decompositions and Least Squares
    [Q, R] = qr(X);            % Orthogonal-triangular decomposition
    b = abtrandn(100, 1);
    x = X \ b;                 % Left division / Least-squares WLM solver

### Case 2: Operating with $\alpha \le 0$ (Restricted to 4D Algebra)
When $\alpha$ is negative or zero, the 8D generalization becomes mathematically undefined. The toolbox restricts operations strictly to the core 4D framework.

    % 1. Configure the environment (e.g., alpha = -1, beta = 1)
    setabtessarine(-1, 1);

    % 2. Generate and operate exclusively with 4D objects
    A = abtrand(50, 50);
    B = abtrand(50, 50);

    % 3. Apply Advanced 4D Spectral Theory
    C = A * B;                 % Native 4D multiplication
    [L, U, P] = lu(A);         % Hypercomplex LU decomposition
    invA = inv(A);             % Fast inverse caching
    [V, D] = eigs(A);          % Dominant eigenvalues and eigenvectors

    % Note: Attempting to multiply or generate 8D objects (gabtessarine) 
    % with an alpha <= 0 environment will throw a safety error.

## Illustrative Examples
For a complete demonstration of the toolbox in action, navigate to the `examples/` directory. The included scripts showcase the software's capabilities across four distinct domains:

* **Signal Processing:** Color image compression via hypercomplex SVD.
* **Physics & Robotics:** Solving kinematic linear systems under noise.
* **High-Performance Computing:** Benchmarking native vectorized operations against standard `for`-loops.
* **Machine Learning:** Fast, derivative-free training of hypercomplex neural networks (ELM classifiers).

## Theoretical Background and Citation
This software is the computational implementation of the theoretical methods described in the accompanying research paper. The algorithms strictly follow the algebraic rules and properties derived for $\alpha\beta$-tessarine spectral theory, including eigendecompositions, isomorphisms, and least squares problem solvers.

If you use this toolbox in your research, please cite the following publication:

> **Jiménez-López, J. D., Navarro-Moreno, J., Fernández-Alcalá, R. M., & Ruiz-Molina, J. C. (2025).** *Advancing Computationak Tools for Analyzing Commutative Hypercomplex Algebras*. arXiv preprint arXiv:2508.02709. 
https://doi.org/10.48550/arXiv.2508.02709

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.

