
function moxon_calculate_dimensions(f_mhz, dia_mm) = 
	let(
		// Calculate wavelength in mm
		c = 299792458,              // Speed of light in m/s
		wavelength_mm = (c / (f_mhz * 1000000)) * 1000,

		// Convert wire diameter to wavelengths
		dia_wavelengths = dia_mm / wavelength_mm,

		// Validate wire diameter range (1E-5 to 1E-2 wavelengths)
		dia_wl_min = 1e-5,
		dia_wl_max = 1e-2,
		dia_valid = (dia_wavelengths >= dia_wl_min && dia_wavelengths <= dia_wl_max),

		// Use log10 of diameter in wavelengths
		log_dia = log(dia_wavelengths) / log(10),  // Convert to common log (base 10)

		// Cebik's empirical coefficients for 50-ohm Moxon
		// A dimension coefficients
		AA = -0.0008571428571,
		AB = -0.009571428571,
		AC = 0.3398571429,

		// B dimension coefficients
		BA = -0.002142857143,
		BB = -0.02035714286,
		BC = 0.008285714286,

		// C dimension coefficients
		CA = 0.001809523381,
		CB = 0.01780952381,
		CC = 0.05164285714,

		// D dimension coefficients
		DA = 0.001,
		DB = 0.07178571429,

		// Calculate dimensions in wavelengths using Cebik's formulas
		A_wl = (AA * pow(log_dia, 2)) + (AB * log_dia) + AC,
		B_wl = (BA * pow(log_dia, 2)) + (BB * log_dia) + BC,
		C_wl = (CA * pow(log_dia, 2)) + (CB * log_dia) + CC,
		D_wl = (DA * log_dia) + DB,
		E_wl = B_wl + C_wl + D_wl,

		// Convert to millimeters
		A_mm = A_wl * wavelength_mm,
		B_mm = B_wl * wavelength_mm,
		C_mm = C_wl * wavelength_mm,
		D_mm = D_wl * wavelength_mm,
		E_mm = E_wl * wavelength_mm,

		// Calculate some useful metrics
		boom_length_wl = E_wl,
		total_wire_length_mm = 2 * (A_mm + E_mm - 2 * C_mm),  // Approximate wire length
		compactness = A_wl / 0.5  // Compared to half-wave dipole
	)
	[A_mm, B_mm, C_mm, D_mm, E_mm, wavelength_mm, dia_valid, boom_length_wl, total_wire_length_mm, compactness];

IDX_WIDTH = 0;
IDX_DRIVER_TAIL_LENGTH = 1;
IDX_GAP_LENGTH = 2;
IDX_REFLECTOR_TAIL_LENGTH = 3;
IDX_HEIGHT = 4;
IDX_WAVELENGTH = 5;
IDX_DIAMETER_VALID = 6;
IDX_BOOM_LENGTH_WAVELENGTHS = 7;
IDX_WIRE_LENGTH_MM = 8;
IDX_COMPACTNESS_FACTOR = 9;