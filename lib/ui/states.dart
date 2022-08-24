import 'dart:convert';

const List<Map<String, dynamic>> US_STATES = [
  {
    "label": "Jack@exchangily.ca (7)",
    "children": [
      {
        "label": "Jack1@exchangily.ca (3)",
        "children": [
          {
            "label": "Jack123231@exchangily.ca (4)",
            "children": [
              {
                "label": "Jyert1323dfdf1@exchangily.ca (0)",
              },
              {
                "label": "Jack12erer31@exchangily.ca (0)",
              },
              {
                "label": "werwer23231@exchangily.ca (0)",
              },
              {
                "label": "werwe23231@exchangily.ca (0)",
              },
            ]
          },
          {
            "label": "Jyert1323dfdf1@exchangily.ca (0)",
          },
          {
            "label": "Jack12erer31@exchangily.ca (0)",
          },
          {
            "label": "werwer23231@exchangily.ca (0)",
          },
          {
            "label": "werwe23231@exchangily.ca (0)",
          },
        ]
      },
      {
        "label": "Jyert1323dfdf1@exchangily.ca (0)",
      },
      {
        "label": "Jack12erer31@exchangily.ca (0)",
      },
      {
        "label": "werwer23231@exchangily.ca (0)",
      },
      {
        "label": "werwe23231@exchangily.ca (0)",
      },
    ]
  },
];

String US_STATES_JSON = jsonEncode(US_STATES);
