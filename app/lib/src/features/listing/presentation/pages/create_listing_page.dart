import 'package:flutter/material.dart';

/// Create listing page — multi-step wizard to announce a property.
class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anunciar imóvel')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 7) setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: const [
          Step(
            title: Text('Tipo'),
            content: Text('Apartamento, Casa, Kitnet, Studio, Cobertura'),
          ),
          Step(
            title: Text('Endereço'),
            content: Text('CEP, Rua, Número, Complemento, Bairro, Cidade, Estado'),
          ),
          Step(
            title: Text('Detalhes'),
            content: Text('Área (m²), Quartos, Banheiros, Vagas, Andar, Mobiliado'),
          ),
          Step(
            title: Text('Amenidades'),
            content: Text('Piscina, Academia, Churrasqueira, Playground, etc.'),
          ),
          Step(
            title: Text('Fotos'),
            content: Text('Upload múltiplo (min 5, max 30)'),
          ),
          Step(
            title: Text('Descrição'),
            content: Text('Descrição detalhada do imóvel'),
          ),
          Step(
            title: Text('Preço'),
            content: Text('Aluguel, Condomínio, IPTU'),
          ),
          Step(
            title: Text('Revisão'),
            content: Text('Preview do anúncio como o inquilino verá'),
          ),
        ],
      ),
    );
  }
}
