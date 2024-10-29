import 'package:flutter/material.dart';

class InputNumber extends StatefulWidget {
  // Atributos do widget
  final String label; // Rótulo para o input
  final Function(int) onChanged; // Função chamada quando o valor muda
  final int value; // Valor atual
  final int min; // Valor mínimo permitido
  final int max; // Valor máximo permitido

  // Construtor do widget com parâmetros obrigatórios
  InputNumber({
    required this.label,
    required this.onChanged,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  _InputNumberState createState() => _InputNumberState();
}

class _InputNumberState extends State<InputNumber> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10), // Espaçamento interno
      child: Row(
        children: <Widget>[
          Text(widget.label), // Exibe o rótulo
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Alinha o conteúdo à direita
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    // Verifica se o valor atual é maior que o mínimo
                    if (widget.value > widget.min) {
                      widget.onChanged(widget.value - 1); // Chama a função onChanged com o novo valor
                    }
                  },
                ),
                Text(widget.value.toString()), // Exibe o valor atual
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Verifica se o valor atual é menor que o máximo
                    if (widget.value < widget.max) {
                      widget.onChanged(widget.value + 1); // Chama a função onChanged com o novo valor
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
