import 'package:decimal/decimal.dart';

class Constants {
  static Pattern regexPattern = r'^(0|(\d+)|\.(\d+))(\.(\d+))?$';
  static Map<String, String> headersText = {"responseType;": "text"};
  static Map<String, String> headersJson = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Decimal decimalZero = Decimal.zero;
  static int clubProjectExpireDays = 7;
  static int tronUsdtFee = 40;
  static int tronFee = 1;

  static String multisigWalletBox = 'multisigWallet';

  static const List<String> specialTokens = [
    'USDTX',
    'USDTM',
    'USDTB',
    'USDCX',
    'FABE',
    'EXGE',
    'DSCE',
    'BSTE',
    'FABB',
    'MATICM',
  ];
  static const String appName = 'Paycool';
  static const String androidStoreId = "club.paycool.paycool";
  static const String appleStoreId = "id1571496540";
/*----------------------------------------------------------------------
                        Pay.cool
----------------------------------------------------------------------*/
  static const String ReferralAddressText = 'referralAddress';
  static const String MerchantAddressText = 'merchantAddress';

  static const String EthChainPrefix = '0003';
  static const String TronChainPrefix = '0007';
  static const String FabChainPrefix = '0002';
  static const String bnbChainPrefix = '0008';
  static const String maticmChainPrefix = '0009';

  static const String depositSignatureAbi = "0x379eb862";
  static const String withdrawSignatureAbi = "0x3295d51e";
  static const String sendSignatureAbi = "0x3faf0a66";
  static const String payCoolClubSignatureAbi = "0x1827a766";
  static const String payCoolRefundAbi = "0x775274a1";
  static const String payCoolCancelAbi = "0x5806abae";
  static const String payCoolSignOrderAbi = "0x09953d6d";
  static const String payCoolCreateAccountAbiCode = "0x9859387b";
  static const String multisigTransferAbiCode = "0x6a761202";

  static const String bondAbiCodeKanban = "0x85d7b238";
  static const String bondAbiCodeEth = "0xd13a00ba";
  static const String bondApproveEthAbiCode = "0x095ea7b3";
  static const String bondApproveKanbanAbiCode = "0x78c94cb5";

  static const String EthMessagePrefix = '\u0019Ethereum Signed Message:\n';
  static const String BtcMessagePrefix = '\x18Bitcoin Signed Message:\n';
  static const String KanbanMessagePrefix = '\u0017Kanban Signed Message:\n';
  static const testAbi = [
    {
      "constant": false,
      "inputs": [
        {
          "components": [
            {"name": "target", "type": "address"},
            {"name": "callData", "type": "bytes"}
          ],
          "name": "calls",
          "type": "tuple[]"
        }
      ],
      "name": "aggregate",
      "outputs": [
        {"name": "blockNumber", "type": "uint256"},
        {"name": "returnData", "type": "bytes[]"}
      ],
      "payable": false,
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ];

  static const exuctionAbiJson = [
    {
      "inputs": [
        {"internalType": "address", "name": "to", "type": "address"},
        {"internalType": "uint256", "name": "value", "type": "uint256"},
        {"internalType": "bytes", "name": "data", "type": "bytes"},
        {
          "internalType": "enum Enum.Operation",
          "name": "operation",
          "type": "uint8"
        },
        {"internalType": "uint256", "name": "safeTxGas", "type": "uint256"},
        {"internalType": "uint256", "name": "baseGas", "type": "uint256"},
        {"internalType": "uint256", "name": "gasPrice", "type": "uint256"},
        {"internalType": "address", "name": "gasToken", "type": "address"},
        {
          "internalType": "address payable",
          "name": "refundReceiver",
          "type": "address"
        },
        {"internalType": "bytes", "name": "signatures", "type": "bytes"}
      ],
      "name": "execTransaction",
      "outputs": [
        {"internalType": "bool", "name": "success", "type": "bool"}
      ],
      "stateMutability": "payable",
      "type": "function"
    }
  ];

  static const String ISRG_X1 = """-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----""";
}
