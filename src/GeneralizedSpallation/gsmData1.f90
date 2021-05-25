
! ======================================================================
!
!    enmax and scalf are calculated from the NASA parametrization.
!
!     Store parameters for calculating approximate optical model
!     reaction cross sections:
!     n   from Mani, Melkanoff and Ior
!     p   from  Becchetti and Greenlees
!     d   from O.M. of Perey and Perey
!     t   from O.M. of Hafele, Flynn et al
!     3He from O.M. of Gibson et al
!     alpha from Huizenga and Igo
!
!    Written by K. Gudima in 2001 from Kalbach's SIGPAR
!    Edited in 2001 by S. Mashnik
!    Edited by AJS, June, 2002.
!    Edited by AJS, September-November, 2003.
!    Edited by AJS, LANL T-2, December, 2011.
!
! ======================================================================

     real(real64), public, parameter, dimension(6) :: xp0 = &
          & [ -312.d0, 15.72d0,  0.798d0, -21.45d0,  -2.88d0,  10.95d0 ]
     real(real64), public, parameter, dimension(6) :: xp1 = &
          & [    0.d0,  9.65d0,  420.3d0,  484.7d0,  205.6d0, -85.21d0 ]
     real(real64), public, parameter, dimension(6) :: xp2 = &
          & [    0.d0, -300.d0, -1651.d0, -1608.d0, -1487.d0,  1146.d0 ]
     real(real64), public, parameter, dimension(6) :: xl0 = &
          & [  12.1d0, 4.37d-3,  6.19d-3,  1.86d-2, 4.59d-3,   6.43d-2 ]
     real(real64), public, parameter, dimension(6) :: xl1 = &
          & [-11.27d0,-16.58d0,  -7.54d0,  -8.90d0,  -8.93d0, -13.96d0 ]
     real(real64), public, parameter, dimension(6) :: xm0 = &
          & [ 234.1d0, 244.7d0,  583.5d0,  686.3d0,  611.2d0,  781.2d0 ]
     real(real64), public, parameter, dimension(6) :: xm1 = &
          & [ 38.26d0, 0.503d0,  0.337d0,  0.325d0,   0.35d0,   0.29d0 ]
     real(real64), public, parameter, dimension(6) :: xn0 = &
          & [  1.55d0, 273.1d0,  421.8d0,  368.9d0,  473.8d0, -304.7d0 ]
     real(real64), public, parameter, dimension(6) :: xn1 = &
          & [-106.1d0,-182.4d0, -474.5d0, -522.2d0, -468.2d0,  -470.d0 ]
     real(real64), public, parameter, dimension(6) :: xn2 = &
          & [1280.8d0,-1.872d0, -3.592d0, -4.998d0, -2.225d0,  -8.58d0 ]


! ======================================================================

     real(real64), public, parameter, dimension(300) :: enmax = &
          ! 1-133
          & [  3.00d0,  6.06d0,  6.64d0,  6.32d0,  6.30d0,  6.24d0,  6.46d0, &
          &    6.24d0,  6.36d0,  5.95d0, 12.94d0,  8.86d0,  8.85d0,  8.70d0, &
          &    8.69d0,  8.63d0,  8.64d0,  9.03d0,  8.99d0,  9.01d0,  8.97d0, &
          &    8.87d0,  8.80d0,  8.66d0,  8.72d0,  8.82d0,  8.81d0,  8.47d0, &
          &    8.47d0,  8.34d0,  8.33d0,  8.21d0,  8.20d0,  8.08d0,  8.07d0, &
          &    7.96d0,  7.94d0,  7.83d0,  8.15d0,  8.75d0,  8.61d0,  8.59d0, &
          &    8.47d0,  8.43d0,  8.41d0,  8.30d0,  8.27d0,  8.17d0,  8.14d0, &
          &    8.09d0,  7.32d0,  7.29d0,  7.21d0,  7.17d0,  7.15d0,  7.07d0, &
          &    7.05d0,  6.97d0,  6.71d0,  6.67d0,  6.63d0,  6.59d0,  6.23d0, &
          &    6.20d0,  6.17d0,  6.46d0,  6.42d0,  6.40d0,  6.38d0,  6.34d0, &
          &    6.32d0,  6.30d0,  6.28d0,  6.25d0,  6.24d0,  6.22d0,  6.21d0, &
          &    6.19d0,  6.17d0,  6.17d0,  6.16d0,  6.15d0,  6.14d0,  6.14d0, &
          &    6.13d0,  6.12d0,  6.12d0,  6.12d0,  6.12d0,  6.11d0,  6.12d0, &
          &    6.14d0,  6.14d0,  6.15d0,  6.16d0,  6.19d0,  6.18d0,  6.21d0, &
          &    6.23d0,  6.24d0,  6.26d0,  6.25d0,  6.31d0,  6.33d0,  6.36d0, &
          &    6.38d0,  6.42d0,  6.45d0,  6.48d0,  6.52d0,  6.55d0,  6.58d0, &
          &    6.62d0,  6.67d0,  6.71d0,  6.74d0,  6.80d0,  6.85d0,  6.89d0, &
          &    6.95d0,  7.00d0,  7.05d0,  7.10d0,  7.16d0,  7.21d0,  7.28d0, &
          &    7.33d0,  7.40d0,  7.46d0,  7.53d0,  7.60d0,  7.68d0,  7.74d0, & ! 1-133
          ! 134-262
          &    7.82d0,  7.89d0,  7.97d0,  8.04d0,  8.12d0,  8.21d0,  8.59d0, &
          &    8.67d0,  8.78d0,  8.85d0,  8.96d0,  9.06d0,  9.13d0,  9.25d0, &
          &    9.33d0,  9.46d0,  9.57d0, &
          &    9.66d0,  9.77d0,  9.87d0,  9.98d0, 10.12d0, 10.22d0, 10.34d0, &
          &   10.47d0, 10.55d0, 10.71d0, 10.83d0, 10.96d0, 11.08d0, 11.22d0, &
          &   11.31d0, 11.47d0, 11.63d0, 11.75d0, 11.90d0, 12.06d0, 12.16d0, &
          &   12.35d0, 12.48d0, 12.64d0, 12.80d0, 12.94d0, 13.11d0, 13.25d0, &
          &   13.42d0, 13.60d0, 13.73d0, 13.91d0, 14.06d0, 14.23d0, 14.44d0, &
          &   14.60d0, 14.78d0, 14.96d0, 15.14d0, 15.31d0, 15.52d0, 15.70d0, &
          &   15.88d0, 16.10d0, 16.30d0, 16.47d0, 16.66d0, 16.86d0, 15.42d0, &
          &   15.45d0, 15.47d0, 15.53d0, 19.97d0, 19.98d0, 20.02d0, 25.02d0, &
          &   24.94d0, 25.06d0, 25.05d0, 25.02d0, 25.10d0, 25.05d0, 25.14d0, &
          &   25.10d0, 25.08d0, 25.16d0, 25.14d0, 25.20d0, 25.18d0, 25.15d0, &
          &   25.22d0, 25.21d0, 25.28d0, 25.27d0, 25.22d0, 25.29d0, 25.28d0, &
          &   25.33d0, 25.31d0, 25.29d0, 25.38d0, 25.34d0, 25.39d0, 25.38d0, &
          &   25.36d0, 25.44d0, 25.40d0, 25.47d0, 25.45d0, 25.43d0, 25.48d0, &
          &   25.45d0, 25.53d0, 25.50d0, 25.49d0, 25.55d0, 25.52d0, 25.58d0, &
          &   25.56d0, 25.55d0, 25.58d0, 25.58d0, 25.66d0, 25.63d0, 25.60d0, &
          &   25.66d0, 25.63d0, 25.68d0, 25.67d0, 25.65d0, 25.68d0, 25.67d0, & ! 134-262
          ! 263-300
          &   25.77d0, 25.71d0, 25.71d0, 25.77d0, 25.77d0, 25.82d0, 25.79d0, &
          &   25.79d0, 25.85d0, 25.82d0, 25.85d0, 25.85d0, 25.84d0, 25.88d0, &
          &   25.88d0, 25.88d0, 25.88d0, 25.88d0, 25.96d0, 25.93d0, 25.96d0, &
          &   25.96d0, 25.94d0, 25.99d0, 25.97d0, 26.03d0, 26.01d0, 25.99d0, &
          &   26.08d0, 26.04d0, 26.10d0, 26.08d0, 26.06d0, 26.12d0, 26.08d0, &
          &   26.14d0, 26.13d0, 26.08d0                                      ] ! 263-300

! ======================================================================

     real(real64), public, parameter, dimension(300) :: scalf = &
          ! 1-100
          & [ 0.000d0, 0.916d0, 1.063d0, 1.038d0, 1.057d0, 1.067d0, 1.121d0, &
          &   1.096d0, 1.128d0, 1.064d0, 0.963d0, 1.035d0, 1.043d0, 1.031d0, &
          &   1.037d0, 1.036d0, 1.043d0, 1.115d0, 1.113d0, 1.118d0, 1.117d0, &
          &   1.109d0, 1.104d0, 1.091d0, 1.100d0, 1.111d0, 1.111d0, 1.079d0, &
          &   1.080d0, 1.069d0, 1.068d0, 1.058d0, 1.057d0, 1.047d0, 1.046d0, &
          &   1.036d0, 1.034d0, 1.025d0, 1.058d0, 1.103d0, 1.100d0, 1.103d0, &
          &   1.101d0, 1.104d0, 1.107d0, 1.105d0, 1.108d0, 1.106d0, 1.108d0, &
          &   1.111d0, 1.057d0, 1.060d0, 1.059d0, 1.062d0, 1.064d0, 1.063d0, &
          &   1.066d0, 1.065d0, 1.050d0, 1.051d0, 1.053d0, 1.054d0, 1.028d0, &
          &   1.029d0, 1.030d0, 1.058d0, 1.059d0, 1.060d0, 1.061d0, 1.062d0, &
          &   1.063d0, 1.064d0, 1.064d0, 1.065d0, 1.066d0, 1.067d0, 1.067d0, &
          &   1.068d0, 1.069d0, 1.069d0, 1.070d0, 1.070d0, 1.071d0, 1.071d0, &
          &   1.071d0, 1.072d0, 1.072d0, 1.072d0, 1.073d0, 1.073d0, 1.073d0, &
          &   1.073d0, 1.073d0, 1.073d0, 1.074d0, 1.074d0, 1.074d0, 1.073d0, &
          &   1.073d0, 1.073d0,                                              & ! 1-100
          ! 101-200
          &   1.073d0, 1.073d0, 1.073d0, 1.072d0, 1.072d0, 1.072d0, 1.072d0, &
          &   1.071d0, 1.071d0, 1.070d0, 1.070d0, 1.069d0, 1.069d0, 1.068d0, &
          &   1.068d0, 1.067d0, 1.067d0, 1.066d0, 1.065d0, 1.064d0, 1.064d0, &
          &   1.063d0, 1.062d0, 1.061d0, 1.061d0, 1.060d0, 1.059d0, 1.058d0, &
          &   1.057d0, 1.056d0, 1.055d0, 1.054d0, 1.053d0, 1.052d0, 1.051d0, &
          &   1.050d0, 1.049d0, 1.048d0, 1.047d0, 1.062d0, 1.061d0, 1.060d0, &
          &   1.058d0, 1.058d0, 1.057d0, 1.056d0, 1.055d0, 1.053d0, 1.053d0, &
          &   1.052d0, 1.050d0, 1.050d0, 1.048d0, 1.047d0, 1.047d0, 1.045d0, &
          &   1.044d0, 1.043d0, 1.042d0, 1.041d0, 1.040d0, 1.039d0, 1.037d0, &
          &   1.036d0, 1.036d0, 1.034d0, 1.033d0, 1.031d0, 1.031d0, 1.030d0, &
          &   1.028d0, 1.028d0, 1.026d0, 1.025d0, 1.025d0, 1.023d0, 1.022d0, &
          &   1.020d0, 1.020d0, 1.019d0, 1.017d0, 1.016d0, 1.014d0, 1.014d0, &
          &   1.013d0, 1.011d0, 1.011d0, 1.009d0, 1.008d0, 1.008d0, 1.006d0, &
          &   1.005d0, 1.003d0, 1.003d0, 1.002d0, 1.000d0, 1.000d0, 0.998d0, &
          &   0.890d0, 0.890d0,                                              & ! 101-200
          ! 201-300
          &   0.890d0, 0.890d0, 0.988d0, 0.988d0, 0.988d0, 1.074d0, 1.073d0, &
          &   1.074d0, 1.073d0, 1.072d0, 1.073d0, 1.072d0, 1.073d0, 1.072d0, &
          &   1.071d0, 1.072d0, 1.071d0, 1.071d0, 1.071d0, 1.070d0, 1.070d0, &
          &   1.070d0, 1.070d0, 1.069d0, 1.069d0, 1.069d0, 1.068d0, 1.069d0, &
          &   1.068d0, 1.067d0, 1.068d0, 1.067d0, 1.068d0, 1.067d0, 1.066d0, &
          &   1.067d0, 1.066d0, 1.067d0, 1.066d0, 1.065d0, 1.066d0, 1.065d0, &
          &   1.066d0, 1.065d0, 1.064d0, 1.065d0, 1.064d0, 1.065d0, 1.064d0, &
          &   1.063d0, 1.064d0, 1.063d0, 1.064d0, 1.063d0, 1.062d0, 1.063d0, &
          &   1.062d0, 1.063d0, 1.062d0, 1.061d0, 1.062d0, 1.061d0, 1.062d0, &
          &   1.061d0, 1.060d0, 1.061d0, 1.060d0, 1.061d0, 1.060d0, 1.059d0, &
          &   1.060d0, 1.059d0, 1.060d0, 1.059d0, 1.058d0, 1.059d0, 1.058d0, &
          &   1.058d0, 1.058d0, 1.057d0, 1.058d0, 1.057d0, 1.058d0, 1.057d0, &
          &   1.056d0, 1.057d0, 1.056d0, 1.057d0, 1.056d0, 1.055d0, 1.056d0, &
          &   1.055d0, 1.056d0, 1.055d0, 1.054d0, 1.055d0, 1.054d0, 1.055d0, &
          &   1.054d0, 1.053d0                                               ] ! 201-300

! ======================================================================
