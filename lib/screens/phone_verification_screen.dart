import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  static const Color primary = Color(0xFF7A5AF8); // Morado PixelChat

  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  bool _showCodeInput = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------------
  // Enviar SMS (simulado)
  // -----------------------------------------------------------------------------
  void _sendCode() {
    if (_phoneController.text.trim().isEmpty) {
      _showError('Ingresa un número de teléfono válido.');
      return;
    }

    setState(() {
      _showCodeInput = true;
    });
  }

  // -----------------------------------------------------------------------------
  // Verificar código
  // -----------------------------------------------------------------------------
  void _verifyCode() {
    final code =
        _otpControllers.map((c) => c.text.trim()).join('').replaceAll(' ', '');

    if (code.length != 6) {
      _showError('Código incompleto');
      return;
    }

    setState(() => _isLoading = true);

    // Simular verificación
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.pushReplacementNamed(context, '/profile-setup');
    });
  }

  void _skipPhoneVerification() {
    Navigator.pushReplacementNamed(context, '/profile-setup');
  }

  // -----------------------------------------------------------------------------
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BOTÓN ATRÁS
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),

              const SizedBox(height: 32),

              // TÍTULO
              Text(
                _showCodeInput
                    ? "Introduce el código"
                    : "Ingrese su número de teléfono",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _showCodeInput
                    ? "Te hemos enviado un SMS con un código de 6 dígitos."
                    : "Confirma tu país e ingresa tu número de teléfono. (Opcional)",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // ------------------------------------------------------------
              // MODO 1: INGRESAR TELÉFONO
              // ------------------------------------------------------------
              if (!_showCodeInput) _buildPhoneInput(),

              // ------------------------------------------------------------
              // MODO 2: INGRESAR CÓDIGO OTP
              // ------------------------------------------------------------
              if (_showCodeInput) _buildOtpInput(),

              const SizedBox(height: 40),

              // BOTÓN CONTINUAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_showCodeInput ? _verifyCode : _sendCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _showCodeInput ? "Verificar código" : "Enviar código",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // SALTAR
              Center(
                child: GestureDetector(
                  onTap: _skipPhoneVerification,
                  child: const Text(
                    "Saltar",
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // WIDGET: INPUT DE TELÉFONO
  // -----------------------------------------------------------------------------
  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        hintText: "Número de teléfono",
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // WIDGET: INPUT DE CÓDIGO OTP
  // -----------------------------------------------------------------------------
  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 48,
              height: 58,
              child: TextField(
                controller: _otpControllers[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                },
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Reenviar código
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                for (var c in _otpControllers) {
                  c.clear();
                }
              });
            },
            child: const Text(
              "Reenviar código",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
