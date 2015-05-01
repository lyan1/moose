[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmax = 0.5
  ymax = 0.5
  elem_type = QUAD4
[]

[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./strain11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./c]
  [../]
  [./eigen_strain_incr00]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./c_IC]
    int_width = 0.15
    x1 = 0
    y1 = 0
    radius = 0.25
    outvalue = 0
    variable = c
    invalue = 1
    type = SmoothCircleIC
  [../]
[]

[Kernels]
  [./TensorMechanics]
    disp_x = disp_x
    disp_y = disp_y
  [../]
[]

[AuxKernels]
  [./strain11]
    type = RankTwoAux
    rank_two_tensor = total_strain
    index_i = 0
    index_j = 0
    variable = strain11
  [../]
  [./stress11]
    type = RankTwoAux
    rank_two_tensor = total_strain
    index_i = 1
    index_j = 1
    variable = stress11
  [../]
  [./eigen_strain_incr00]
    type = RankTwoAux
    variable = eigen_strain_incr00
    rank_two_tensor = stress_free_strain_increment
    index_j = 0
    index_i = 0
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    block = 0
    C_ijkl = '1 1'
    fill_method = symmetric_isotropic
  [../]
  [./var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    function = 0.01*c^2
    args = c
    outputs = exodus
    output_properties = 'var_dep'
    f_name = var_dep
    enable_jit = true
    derivative_order = 2
  [../]
  [./eigen_strain]
    type = Compute1PhaseEigenStrain
    block = 0
    eigen_base = '1 1 1 0 0 0'
    v = c
    incremental_form = true
  [../]
  [./strain]
    type = ComputeFiniteStrain
    block = 0
    disp_x = disp_x
    disp_y = disp_y
  [../]
  [./stress]
    type = ComputeFiniteStrainElasticStress
    block = 0
  [../]
[]

[BCs]
  [./bottom_y]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./left_x]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./top_y]
    type = FunctionPresetBC
    variable = disp_y
    boundary = top
    function = 0.0005*t
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 3
  solve_type = PJFNK
  petsc_options_iname = '-pc_type '
  petsc_options_value = lu
  l_max_its = 20
  nl_max_its = 10
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-9
  reset_dt = true
[]

[Outputs]
  exodus = true
  output_on = timestep_end
  [./console]
    type = Console
    perf_log = true
    output_on = 'initial timestep_end failed nonlinear'
  [../]
[]
