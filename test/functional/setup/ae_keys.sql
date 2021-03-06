/* DROP Column Encryption Key first, Column Master Key cannot be dropped until no encryption depends on it */
IF EXISTS (SELECT * FROM sys.column_encryption_keys WHERE [name] LIKE '%AEColumnKey%')

BEGIN
DROP COLUMN ENCRYPTION KEY [AEColumnKey]
END
GO

/* Can finally drop Column Master Key after the Encryption Key is dropped */
IF EXISTS (SELECT * FROM sys.column_master_keys WHERE [name] LIKE '%AEMasterKey%')

BEGIN
DROP COLUMN MASTER KEY [AEMasterKey]
END
GO

/* Recreate the Column Master Key */
CREATE COLUMN MASTER KEY [AEMasterKey]
WITH
(
	KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
	KEY_PATH = N'CurrentUser/my/237F94738E7F5214D8588006C2269DBC6B370816'
)
GO

/* Create Column Encryption Key using the Column Master Key */
/* ENCRYPTED_VALUE is generated by SSMS and it is always the same if the same Certificate is imported */
CREATE COLUMN ENCRYPTION KEY [AEColumnKey]
WITH VALUES
(
	COLUMN_MASTER_KEY = [AEMasterKey],
	ALGORITHM = 'RSA_OAEP',
	ENCRYPTED_VALUE = 0x016E000001630075007200720065006E00740075007300650072002F006D0079002F00320033003700660039003400370033003800650037006600350032003100340064003800350038003800300030003600630032003200360039006400620063003600620033003700300038003100360039DE2397A08F6313E7820D75382D8469BE1C8F3CD47E3240A5A6D6F82D322F6EB1B103C9C47999A69FFB164D37E7891F60FFDB04ADEADEB990BE88AE488CAFB8774442DF909D2EF8BB5961A5C11B85BA7903E0E453B27B49CE0A30D14FF4F412B5737850A4C564B44C744E690E78FAECF007F9005E3E0FB4F8D6C13B016A6393B84BB3F83FEED397C4E003FF8C5BBDDC1F6156349A8B40EDC26398C9A03920DD81B9197BC83A7378F79ECB430A04B4CFDF3878B0219BB629F5B5BF3C2359A7498AD9A6F5D63EF15E060CDB10A65E6BF059C7A32237F0D9E00C8AC632CCDD68230774477D4F2E411A0E4D9B351E8BAA87793E64456370D91D4420B5FD9A252F6D9178AE3DD02E1ED57B7F7008114272419F505CBCEB109715A6C4331DEEB73653990A7140D7F83089B445C59E4858809D139658DC8B2781CB27A749F1CE349DC43238E1FBEAE0155BF2DBFEF6AFD9FD2BD1D14CEF9AC125523FD1120488F24416679A6041184A2719B0FC32B6C393FF64D353A3FA9BC4FA23DFDD999B0771A547B561D72B92A0B2BB8B266BC25191F2A0E2F8D93648F8750308DCD79BE55A2F8D5FBE9285265BEA66173CD5F5F21C22CC933AE2147F46D22BFF329F6A712B3D19A6488DDEB6FDAA5B136B29ADB0BA6B6D1FD6FBA5D6A14F76491CB000FEE4769D5B268A3BF50EA3FBA713040944558EDE99D38A5828E07B05236A4475DA27915E
)
GO