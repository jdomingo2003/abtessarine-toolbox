# abtessarine_Toolbox

**Version:** 1.0.0 (SoftwareX Submission)
**Date:** 11-Apr-2026

## Overview
The **abtessarine_Toolbox** is a high-performance, object-oriented MATLAB library designed for the analysis and manipulation of commutative hypercomplex algebras. 

This toolbox provides a robust computational framework for **$\alpha\beta$-tessarines** ($\alpha \in \mathbb{R}\setminus\{0\}, \beta > 0$), a 4-dimensional hypercomplex algebra that encompasses generalized Segre's quaternions (GSQ) and elliptic quaternions as particular cases. Unlike traditional non-commutative quaternions, tessarines preserve both commutativity and associativity, which significantly enhances their compatibility with advanced linear algebra methods and spectral theory. 

Furthermore, the toolbox extends this mathematical framework to an 8-dimensional algebra known as **generalized $\alpha\beta$-tessarines** ($\mathbb{G}_{\alpha\beta}$) via the Cayley-Dickson construction ($x = x_1 + x_2 \epsilon$, where $\epsilon^2 = -1$).

## 📂 Repository Structure

To maintain a clean architecture, the toolbox is structured into core classes, root-level generators, and a dual-tier validation suite.

* <details>
  <summary><b>@abtessarine/</b> <i>(Core 4D Parametric Tessarine Class)</i></summary>

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
  <summary><b>@gabtessarine/</b> <i>(Generalized 8D Hypercomplex Class)</i></summary>

  | | | | |
  | :--- | :--- | :--- | :--- |
  | `disp` | `gabtessarine` | `horzcat` | `inv` |
  | `kron` | `minus` | `mtimes` | `plus` |
  | `size` | `sqrtm` | `subsasgn` | `subsref` |
  | `times` | `uminus` | `vertcat` | |

  </details>

* <details open>
  <summary><b>tests/</b> <i>(Validation Framework)</i></summary>

  * <details>
    <summary><b>general_tests/</b> <i>(High-level algebraic & stress tests)</i></summary>

    * `test_01_CORE_properties.m`
    * `test_02_matrix_calculus.m`
    * `test_03_advanced_factorizations.m`
    * `test_04_gabtessarine_algebra.m`
    </details>

  * <details open>
    <summary><b>individual_tests/</b> <i>(Unit-level verification)</i></summary>

    * <details>
      <summary>📂 <b>tests_@abtessarine/</b> <i>(Contains unit tests for all 4D methods)</i></summary>

      | | | | |
      | :--- | :--- | :--- | :--- |
      | `test_abtessarine.m` | `test_associated.m` | `test_augmented.m` | `test_cat.m` |
      | `test_chol.m` | `test_conj_i.m` | `test_conj_j.m` | `test_conj_k.m` |
      | `test_ctranspose.m` | `test_det.m` | `test_diag.m` | `test_diff.m` |
      | `test_disp.m` | `test_eig.m` | `test_eigs.m` | `test_hermitian.m` |
      | `test_horzcat.m` | `test_inv.m` | `test_kron.m` | `test_length.m` |
      | `test_lu.m` | `test_minus.m` | `test_mldivide.m` | `test_mpower.m` |
      | `test_mrdivide.m` | `test_mtimes.m` | `test_ndims.m` | `test_norm.m` |
      | `test_permute.m` | `test_pinv.m` | `test_plus.m` | `test_power.m` |
      | `test_prod.m` | `test_qr.m` | `test_repmat.m` | `test_reshape.m` |
      | `test_size.m` | `test_sqrtm.m` | `test_squeeze.m` | `test_subsasgn.m` |
      | `test_subsref.m` | `test_sum.m` | `test_svd.m` | `test_svds.m` |
      | `test_times.m` | `test_trace.m` | `test_transpose.m` | `test_uminus.m` |
      | `test_uplus.m` | `test_vertcat.m` | | |

      </details>

    * <details>
      <summary>📂 <b>tests_@gabtessarine/</b> <i>(Contains unit tests for all 8D methods)</i></summary>

      | | | | |
      | :--- | :--- | :--- | :--- |
      | `test_disp.m` | `test_gabtessarine.m` | `test_horzcat.m` | `test_inv.m` |
      | `test_kron.m` | `test_minus.m` | `test_mtimes.m` | `test_plus.m` |
      | `test_size.m` | `test_sqrtm.m` | `test_subsasgn.m` | `test_subsref.m` |
      | `test_times.m` | `test_uminus.m` | `test_vertcat.m` | |

      </details>

    * 📄 `test_abt2gabt.m`
    * 📄 `test_abteye.m` / `test_gabteye.m`
    * 📄 `test_abtones.m`
    * 📄 `test_abtpdm.m`
    * 📄 `test_abtrand.m` / `test_gabtrand.m`
    * 📄 `test_abtrandn.m` / `test_gabtrandn.m`
    * 📄 `test_abtzeros.m` / `test_gabtzeros.m`
    * 📄 `test_getabtessarine.m`
    * 📄 `test_setabtessarine.m`
    </details>
  </details>

* <details>
  <summary><b>examples/</b> <i>(Application Tutorials)</i></summary>

  * `example_1.m` *(Signal Processing: Color image compression via hypercomplex SVD)*
  * `example_2.m` *(Physics & Robotics: Solving kinematic linear systems under noise)*
  * `example_3.m` *(High-Performance Computing: Scalability benchmark vs for-loops)*
  * `example_4.m` *(Machine Learning: Fast analytical training of ELM classifiers)*
  </details>

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

The `abtessarine_Toolbox` is designed with an intuitive Object-Oriented Architecture, allowing you to operate with hypercomplex numbers and matrices exactly as you would with standard real numbers in MATLAB. 

This guide breaks down the fundamental steps, from configuring the topological space to performing advanced spectral factorizations.

### 1. Global Configuration
Before defining any hypercomplex variables, the global topological space (defined by $\alpha$ and $\beta$) must be configured. 

```matlab
% Set the global topological parameters (e.g., alpha = -1, beta = 2)
setabtessarine(-1, 2);

% You can retrieve the current environment parameters at any time
[alpha, beta] = getabtessarine();
```

### 2. Working with Scalars (Single Hypercomplex Numbers)
You don't need to jump straight into matrices. You can instantiate and manipulate single 4D $\alpha\beta$-tessarine numbers using their four real components ($w, x, y, z$).

```matlab
% Define individual hypercomplex numbers
a = abtessarine(1, 2, 3, 4);   % a = 1 + 2i + 3j + 4k
b = abtessarine(5, -1, 0, 2);  % b = 5 - 1i + 0j + 2k

% Standard Arithmetic
c = a + b;       % Addition
d = a - b;       % Subtraction
e = a * b;       % Multiplication (Commutative in 4D!)
f = a / b;       % Right division (a * inv(b))

% Properties and Involutions
n = norm(a);     % Euclidean norm
a_conj = a';     % Conjugate (Hermitian transpose for a 1x1 scalar)
a_i = conj_i(a); % Directional involution along the i-axis
```

### 3. Matrix Construction and Allocation
The toolbox provides memory-efficient auxiliary generators to easily construct hypercomplex arrays. Furthermore, you can naturally construct and modify matrices element-by-element using standard MATLAB indexing.

```matlab
% Zero-cost memory allocation and identity matrices
Z = abtzeros(100, 100);    % 100x100 4D zero matrix
I = abteye(5);             % 5x5 identity matrix
O = abtones(3, 3);         % 3x3 array of ones

% Random matrix generation (uniform and normal distributions)
M1 = abtrand(3, 3);
M2 = abtrandn(3, 3);

% Element-by-element construction using overloaded indexing
% (Preallocation with abtzeros is recommended for performance)
A = abtzeros(2, 2); 
A(1,1) = abtessarine(1, 2, 3, 4);
A(1,2) = abtessarine(5, -1, 0, 2);
A(2,1) = abtessarine(0, 0, 1, -1);
A(2,2) = A(1,1)';          % Assigning the conjugate of A(1,1)

% Horizontal and Vertical block concatenation
Concat = [A, abteye(2);          
          abtzeros(2), A];         
```

### 4. Matrix Calculus and Spectral Theory (4D)
A major contribution of this toolbox is the native support for exact hypercomplex matrix decompositions using underlying optimized LAPACK routines.

```matlab
% Generate random matrices
A_mat = abtrandn(5, 3);
SqMat = abtrandn(4, 4);

% 1. Standard Matrix Calculus
invSq = inv(SqMat);        % Fast matrix inversion
detSq = det(SqMat);        % Hypercomplex determinant
trSq  = trace(SqMat);      % Trace

% 2. Decompositions (LU, QR, SVD)
[L, U, P] = lu(A_mat);     % LU factorization with partial pivoting
[Q, R]  = qr(A_mat);       % Orthogonal-triangular QR decomposition
[U_svd, S_svd, V_svd] = svd(A_mat); % Singular Value Decomposition

% Verify the SVD reconstruction accuracy
A_reconstructed = U_svd * S_svd * V_svd';
error_norm = norm(A_mat - A_reconstructed);
disp(['SVD Error: ', num2str(error_norm)]);

% 3. Eigenvalue Problems
[V_eig, D_eig] = eig(SqMat);  % Full set of eigenvalues/eigenvectors

% For sparse/dominant subset extraction (eigs), the matrix must 
% exhibit Hermitian symmetry to guarantee convergence:
SqMat_herm = SqMat + SqMat'; 
[V_sub, D_sub] = eigs(SqMat_herm, 2);
```

### 5. 8D Generalized Tessarines (Cayley-Dickson Construction)
The toolbox seamlessly expands to 8-dimensional non-commutative and non-associative algebras via the `@gabtessarine` class. 

⚠️ **Mathematical Constraint:** The 8D Cayley-Dickson generalization is only mathematically defined when the structural parameter $\alpha$ is strictly positive.

```matlab
% Reconfigure environment for 8D support (alpha > 0)
setabtessarine(2, 4);

% 1. Construct an 8D matrix from two existing 4D arrays (Doubling process)
A_4D = abtrand(3, 3);
B_4D = abtrand(3, 3);
G8 = abt2gabt(A_4D, B_4D);

% 2. Instantiate 8D scalars or arrays directly
h8 = gabtessarine(1, 2, 3, 4, 5, 6, 7, 8); % 8 real components
H8 = gabteye(3);

% 3. Generalized 8D Matrix Operations
% The toolbox automatically handles the non-commutative rules internally
Res_add  = G8 + H8;
Res_mult = G8 * H8;        % 8D Matrix multiplication
G8_inv   = inv(G8);        % 8D Matrix inverse
K_8D     = kron(G8, H8);   % 8D Kronecker tensor product

% Display the internal structure of the resulting 8D object
disp(K_8D);
```

## 🔬 Illustrative Examples & Benchmarks

To see the toolbox in action, check out the `examples/` directory. We provide three high-performance signal processing applications that demonstrate its computational speed, mathematical robustness, and scalability:

1. **Color Image In-painting:** Recovers missing pixels in severely damaged images using a Hypercomplex Singular Value Thresholding (SVT) algorithm.
2. **Global Image Denoising:** Removes Additive White Gaussian Noise (AWGN) from high-resolution images using exact, dense SVD factorizations.
3. **Digital Image Watermarking:** Embeds invisible, energy-preserving watermarks using the hypercomplex QR decomposition.

### Extreme-Scale Dataset
We deliberately avoid low-resolution "toy" examples. To truly test memory limits and computational bottlenecks, our examples process massive datasets under real-world conditions:

| Image Name | Native Dimensions | Credit & License | Source Link |
| :--- | :--- | :--- | :--- |
| **Autumn Forest** | 5464 × 3640 | Unsplash (ML6kHR--Uys) | [View Source](https://unsplash.com/es/fotos/un-bosque-lleno-de-muchos-arboles-de-diferentes-colores-ML6kHR--Uys) |
| **Modern Architecture** | 3911 × 5867 | Unsplash (Opwvoz9zwYk) | [View Source](https://unsplash.com/es/fotos/un-edificio-muy-alto-con-muchas-ventanas-Opwvoz9zwYk) |
| **San Francisco** | 5304 × 7952 | Unsplash (o8Utw2ETExA) | [View Source](https://unsplash.com/es/fotos/puente-golden-state-san-francisco-o8Utw2ETExA) |
| **Carina Nebula** | 14575 × 8441 | NASA/ESA/CSA/STScI (Public Domain) | [View Source](https://science.nasa.gov/asset/webb/cosmic-cliffs-in-the-carina-nebula-nircam-image/) |

> 💡 **Why this matters (The Carina Nebula Test):** > Processing the *Carina Nebula* (~123 megapixels) with traditional **quaternion** algorithms requires generating a massive $29150 \times 16882$ complex matrix. This consumes **~7.33 GB of RAM** just to store the inputs, frequently crashing standard workstations with Out-Of-Memory (OOM) errors. 
> 
> By leveraging the idempotent representation of commutative **tessarines**, this toolbox mathematically decouples the problem. This **cuts the memory footprint by more than half**, enabling ultra-high-resolution tensor processing on standard commodity hardware.

## Theoretical Background and Citation
This software is the computational implementation of the theoretical methods described in the accompanying research paper. The algorithms strictly follow the algebraic rules and properties derived for $\alpha\beta$-tessarine spectral theory, including eigendecompositions, isomorphisms, and least squares problem solvers.

If you use this toolbox in your research, please cite the following publication:

> **Jiménez-López, J. D., Navarro-Moreno, J., Fernández-Alcalá, R. M., & Ruiz-Molina, J. C. (2025).** *Advancing Computationak Tools for Analyzing Commutative Hypercomplex Algebras*. arXiv preprint arXiv:2508.02709. 
https://doi.org/10.48550/arXiv.2508.02709

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.

