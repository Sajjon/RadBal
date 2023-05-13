# RadBal

## Instructions
1. Clone this repo
2. Go to the root of your local clone of this repo
3. In the project root, create a file called `.profile.json` being a JSON object like this
```json
{
	"name": "Software wallet",
	"accounts":
	[
		{
			"index": 0,
			"name": "Primary account",
			"address": "rdx1qsp05ckm5zvngyp42m8wvehf8y0jwax4h66sfgj88g8frxa8pctk55ck2emx6"
		},
		{
			"index": 1,
			"name": "Secondary account",
			"address": "rdx1qspsgtz8wxzhs7h3m5dxz4uw0a350qp567zz4v9xgamcag8kavsxvpctcgge2",
			"trades": [
				{
					"rri": "oci_rr1qws04shqrz3cdjljdp5kczgv7wd3jxytagk95qlk7ecquzq8e7",
					"name": "Ociswap",
					"altcoinAmountString": "1291",
					"xrdAmountSpentString": "2500",
					"purchaseDate": "2023-05-13T07:30:00+0000"
				},
				{
					"rri": "caviar_rr1qvnxng85y762xs3fklvxmequaww8k0nhraqv7nqjvmxs4ahu3d",
					"name": "CaviarNine",
					"altcoinAmountString": "32216",
					"xrdAmountSpentString": "2500",
					"purchaseDate": "2023-05-13T07:30:00+0000"
				},
			]
		}
	]
}
```
4. Run: `swift run`

Optionally you can also add another wallet, on the same format, with the name `.profile.legacy.json` if you have migrated from on older wallet, that you might wanna continue to monitor.