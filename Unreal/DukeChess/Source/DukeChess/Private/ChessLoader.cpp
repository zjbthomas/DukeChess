// Fill out your copyright notice in the Description page of Project Settings.


#include "ChessLoader.h"

#include "Engine/Texture2D.h"

#include "Modules/ModuleManager.h"

#include "Misc/Paths.h"
#include "Misc/FileHelper.h"

// For JSON
#include "Serialization/JsonReader.h"
#include "Serialization/JsonSerializer.h"
#include "Dom/JsonObject.h"

// For image
#include "IImageWrapperModule.h"
#include "IImageWrapper.h"

#include "GlobalGameInstance.h"

ChessLoader::ChessLoader(UGlobalGameInstance* InGlobal)
{
	// Load GlobalGameInstance
	Global = InGlobal;
}

ChessLoader::~ChessLoader()
{
}

LoadChessResult ChessLoader::LoadChess() {
	LoadChessResult R;

	if (Global->bLocal && !Global->bAI) {
		if (!FPlatformFileManager::Get().GetPlatformFile().DirectoryExists(*SAVEDCHESSPATH)) {
            // Copy default chess files to saved dir
            if (!CopyToSaved(R)) return R;
		}
	}

	if (Global->bLocal && !Global->bAI) {
		if (!LoadChessFromContent(R)) return R;
	}
	else {
		if (!LoadChessFromSaved(R)) return R;
	}

	return R;
}

static bool ParseManifestLine(const FString& Line, ManifestEntry& OutEntry)
{
	FString L = Line;
	L.TrimStartAndEndInline();

	// Case 1: no comma => single item (e.g. chess_amount.json)
	if (!L.Contains(TEXT(",")))
	{
		// Treat as a json-like single file entry
		OutEntry.JSONRelPath = L;
		OutEntry.PNGRelPath.Reset();
		return true;
	}

	// Case 2: "jsonPath,pngPathOrDash"
	FString Left, Right;
	if (!L.Split(TEXT(","), &Left, &Right))
	{
		return false;
	}

	Left.TrimStartAndEndInline();
	Right.TrimStartAndEndInline();

	if (Left.IsEmpty())
	{
		return false;
	}

	OutEntry.JSONRelPath = Left;

	// "-" means no png
	if (Right.Equals(TEXT("-"), ESearchCase::CaseSensitive) || Right.IsEmpty())
	{
		OutEntry.PNGRelPath.Reset();
	}
	else
	{
		OutEntry.PNGRelPath = Right;
	}

	return true;
}

TArray<ManifestEntry> ChessLoader::ReadManifestEntries(LoadChessResult& R)
{
	const FString ManifestPath = CONTENTCHESSPATH / CHESSMANIFEST;

	FString ManifestText;
	if (!FFileHelper::LoadFileToString(ManifestText, *ManifestPath))
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Failed to load manifest: %s"), *ManifestPath);
		return {};
	}

	TArray<FString> Lines;
	ManifestText.ParseIntoArrayLines(Lines, /*bCullEmpty*/ true);

	TArray<ManifestEntry> Entries;
	Entries.Reserve(Lines.Num());

	for (const FString& Line : Lines)
	{
		ManifestEntry Entry;
		if (ParseManifestLine(Line, Entry))
		{
			// Normalize slashes for safety
			Entry.JSONRelPath.ReplaceInline(TEXT("\\"), TEXT("/"));
			Entry.PNGRelPath.ReplaceInline(TEXT("\\"), TEXT("/"));

			Entries.Add(MoveTemp(Entry));
		}
	}

	return Entries;
}

bool ChessLoader::CopyToSaved(LoadChessResult& R)
{
	TArray<ManifestEntry> Entries = ReadManifestEntries(R);

	if (!R.bOK) return false;

	for (const ManifestEntry& E : Entries)
    {
        // No need to copy chess_amount_online.json
        if (E.JSONRelPath.Equals(CHESSAMOUNTJSONONLINE, ESearchCase::IgnoreCase))
        {
            continue;
        }

		// Copy JSON always
		CopyFile(CONTENTCHESSPATH / E.JSONRelPath, SAVEDCHESSPATH / E.JSONRelPath);

		// Copy PNG only if present
		if (!E.PNGRelPath.IsEmpty())
		{
			CopyFile(CONTENTCHESSPATH / E.PNGRelPath, SAVEDCHESSPATH / E.PNGRelPath);
		}
    }

	return true;
}

bool ChessLoader::CopyFile(const FString& PakFilePath, const FString& DestFilePath) {
    TArray<uint8> Data;
    if (!FFileHelper::LoadFileToArray(Data, *PakFilePath))
    {
        return false;
    }

    // Ensure destination directory exists
    FString DestDir = FPaths::GetPath(DestFilePath);
    IPlatformFile& PF = FPlatformFileManager::Get().GetPlatformFile();
    PF.CreateDirectoryTree(*DestDir);

    return FFileHelper::SaveArrayToFile(Data, *DestFilePath);
}

bool ChessLoader::LoadChessFromContent(LoadChessResult& R) {
	TArray<ManifestEntry> Entries = ReadManifestEntries(R);

	if (!R.bOK) return false;

	for (const ManifestEntry& E : Entries)
	{
		if (E.JSONRelPath.Equals(CHESSAMOUNTJSONONLINE, ESearchCase::IgnoreCase) || E.JSONRelPath.Equals(CHESSAMOUNTJSON, ESearchCase::IgnoreCase))
		{
			continue;
		}

		FString Filename = CONTENTCHESSPATH / E.JSONRelPath;

		FString ImagePath = (!E.PNGRelPath.IsEmpty()) ? CONTENTCHESSPATH / E.PNGRelPath : TEXT("");

		if (!LoadChessFromJSON(Filename, TEXT(""), ImagePath, R)) return false;
	}

	// Set default chess num from JSON
	FString Filename = CONTENTCHESSPATH / ((Global->bLocal && !Global->bAI)? CHESSAMOUNTJSON : CHESSAMOUNTJSONONLINE);

	if (!LoadChessMaxAmount(Filename, R)) return false;

	return true;
}

bool ChessLoader::LoadChessFromSaved(LoadChessResult& R) {
	// Find all subfolders
	TArray<FString> SubDirs;
	IFileManager::Get().FindFiles(SubDirs, *(SAVEDCHESSPATH / TEXT("*")), /*Files=*/false, /*Directories=*/true);

	for (const FString& DirName : SubDirs)
	{
		const FString JsonPath = FPaths::Combine(SAVEDCHESSPATH, DirName, DirName + TEXT(".json"));
		if (!IFileManager::Get().FileExists(*JsonPath))
		{
			R.bOK = false;
			R.ErrorMsg = FString::Printf(TEXT("%s not exists"), *JsonPath);
			return false;
		}

		FString ImagePath = FPaths::Combine(SAVEDCHESSPATH, DirName, DirName + TEXT(".png"));
		if (!IFileManager::Get().FileExists(*ImagePath))
		{
			ImagePath = TEXT("");
		}

		if (!LoadChessFromJSON(JsonPath, TEXT(""), ImagePath, R)) return false;
	}

	// Set default chess num from JSON
	FString Filename = SAVEDCHESSPATH / CHESSAMOUNTJSON;

	if (!LoadChessMaxAmount(Filename, R)) return false;

	return true;
}

bool ChessLoader::LoadChessFromJSON(const FString& Filename, const FString& ForceName, const FString& ImagePath, LoadChessResult& R) {
	FString JsonText;
	if (!FFileHelper::LoadFileToString(JsonText, *Filename))
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Failed to read json: %s"), *Filename);
		return false;
	}

	TSharedPtr<FJsonObject> Root;

	TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(JsonText);
	if (!FJsonSerializer::Deserialize(Reader, Root) || !Root.IsValid())
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Invalid json format: %s"), *Filename);
		return false;
	}

	TSharedPtr<ChessModel> Chess = MakeShared<ChessModel>();

	// Name
	FString Name;
	if (!Root->TryGetStringField(TEXT("name"), Name))
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Missing field 'name' in %s"), *Filename);
		return false;
	}

	// Force name check
	if (!ForceName.IsEmpty() && !Name.Equals(ForceName)) {
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Field 'name' in %s not equals to %s"), *Filename, *ForceName);
		return false;
	}

	// Length of name should not be too long
	if (Name.Len() > 12) { // TODO: magic number
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("'Name' in %s too long"), *Filename);
		return false;
	}

	Chess->Name = Name;

	// Version
	int32 Version;
	if (!Root->TryGetNumberField(TEXT("version"), Version)) Version = 1;

	Chess->Version = Version;

	// TODO: Locale

	// Center offsets
	const TSharedPtr<FJsonObject>* Centers;
	if (Root->TryGetObjectField(TEXT("center"), Centers) && Centers)
	{
		FString FrontCenterDest;
		if ((*Centers)->TryGetStringField(TEXT("front"), FrontCenterDest)) {
			Chess->FrontCenterOffset = UGlobalGameInstance::DestToOffsetsForChess(FrontCenterDest);
		}

		FString BackCenterDest;
		if ((*Centers)->TryGetStringField(TEXT("back"), BackCenterDest)) {
			Chess->BackCenterOffset = UGlobalGameInstance::DestToOffsetsForChess(BackCenterDest);
		}
	}

	// Front movements
	if (!ParseMovements(Root, TEXT("front-movements"), Chess->FrontMap, R, Filename)) return false;

	// Back movements
	if (!ParseMovements(Root, TEXT("back-movements"), Chess->BackMap, R, Filename)) return false;

	// Front auras
	if (!ParseAura(Root, TEXT("front-auras"), Chess->FrontAuraMap, R, Filename)) return false;

	// Back auras
	if (!ParseAura(Root, TEXT("back-auras"), Chess->BackAuraMap, R, Filename)) return false;

	// Load image
	Chess->Texture = (!ImagePath.IsEmpty()) ? LoadTexture2DFromFile(ImagePath) : nullptr;

	// Add chess to list
	ChessNameArray.Add(Name);
	ChessModelMap.Add(Name, Chess);

	return true;
}

bool ChessLoader::LoadChessMaxAmount(const FString& Filename, LoadChessResult& R) {
	FString JsonText;
	if (!FFileHelper::LoadFileToString(JsonText, *Filename))
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Failed to read json: %s"), *Filename);
		return false;
	}

	TSharedPtr<FJsonObject> Root;

	TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(JsonText);
	if (!FJsonSerializer::Deserialize(Reader, Root) || !Root.IsValid())
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Invalid json format: %s"), *Filename);
		return false;
	}

	for (const FString Name : ChessNameArray) {
		int32 Amount;
		if (!Root->TryGetNumberField(Name, Amount)) Amount = 0;

		// Some special rules
		if (Name.Equals(TEXT("Duke"), ESearchCase::IgnoreCase)) {
			if (Amount != 1) {
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Amount for Duke is not 1 in %s"), *Filename);
				return false;
			}
		}

		if (Name.Equals(TEXT("Footman"), ESearchCase::IgnoreCase)) {
			if (Amount < 2) {
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Amount for Footman is smaller than 2 in %s"), *Filename);
				return false;
			}
		}

		ChessMaxAmountMap.Add(Name, Amount);
	}

	return true;
}

bool ChessLoader::ParseMovements(TSharedPtr<FJsonObject>& Root, FString Key, TMap<EActionType, TMap<FString, EMovementType>>& InMap, LoadChessResult& R, const FString& Filename) {
	const TArray<TSharedPtr<FJsonValue>>* Movements;
	if (Root->TryGetArrayField(Key, Movements) && Movements) {
		for (const TSharedPtr<FJsonValue>& V : *Movements)
		{
			// Check if V is Object
			if (!V.IsValid() || V->Type != EJson::Object)
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Invalid '%s' field in %s"), *Key, *Filename);
				return false;
			}

			// Check if V is valid Object
			TSharedPtr<FJsonObject> Obj = V->AsObject();
			if (!Obj.IsValid())
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Invalid '%s' field in %s"), *Key, *Filename);
				return false;
			}

			ParseMovementsResult PMR;
			if (!ParseSingleMovement(Obj, R, Filename, PMR)) return false;

			InMap.Add(PMR.ActionType, PMR.TargetMap);
		}
	}
	else {
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Missing '%s' field in %s"), *Key, *Filename);
		return false;
	}

	return true;
}

bool ChessLoader::ParseSingleMovement(TSharedPtr<FJsonObject>& Parent, LoadChessResult& R, const FString& Filename, ParseMovementsResult& PMR) {
	TMap<FString, EMovementType> TargetMap;

	const TArray<TSharedPtr<FJsonValue>>* Targets;
	if (Parent->TryGetArrayField(TEXT("targets"), Targets) && Targets) {
		for (const TSharedPtr<FJsonValue>& VT : *Targets)
		{
			// Check if V is Object
			if (!VT.IsValid() || VT->Type != EJson::Object)
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Invalid field in 'targets' in %s"), *Filename);
				return false;
			}

			// Check if V is valid Object
			TSharedPtr<FJsonObject> Obj = VT->AsObject();
			if (!Obj.IsValid())
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Invalid field in 'targets' in %s"), *Filename);
				return false;
			}

			FString Type;
			if (!Obj->TryGetStringField(TEXT("type"), Type))
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Missing field 'type' in %s"), *Filename);
				return false;
			}

			const TArray<TSharedPtr<FJsonValue>>* Destinations;
			if (Obj->TryGetArrayField(TEXT("destination"), Destinations))
			{
				for (const TSharedPtr<FJsonValue>& VD : *Destinations)
				{
					FString Dest = VD->AsString();

					// TODO: validate type and destination

					EMovementType MovementType;
					if (!MovementManager::TryParseMovementType(Type, MovementType)) {
						R.bOK = false;
						R.ErrorMsg = FString::Printf(TEXT("Invalid movement type %s in %s"), *Type, *Filename);
						return false;
					}

					TargetMap.Add(Dest, MovementType);
				}
			}
			else {
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Missing field 'destination' in %s"), *Filename);
				return false;
			}
		}
	}
	else {
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Missing field 'targets' in %s"), *Filename);
		return false;
	}

	FString Action;
	if (!Parent->TryGetStringField(TEXT("action"), Action))
	{
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Missing field 'action' in %s"), *Filename);
		return false;
	}
	
	// TODO: validate action

	EActionType ActionType;
	if (!ChessModel::TryParseActionType(Action, ActionType)) {
		R.bOK = false;
		R.ErrorMsg = FString::Printf(TEXT("Invalid action type %s in %s"), *Action, *Filename);
		return false;
	}

	PMR.ActionType = ActionType;
	PMR.TargetMap = TargetMap;

	return true;
}

bool ChessLoader::ParseAura(TSharedPtr<FJsonObject>& Root, FString Key, TMap<EAuraType, TArray<FString>>& InMap, LoadChessResult& R, const FString& Filename) {
	const TArray<TSharedPtr<FJsonValue>>* Auras;
	if (Root->TryGetArrayField(Key, Auras) && Auras) {
		for (const TSharedPtr<FJsonValue>& V : *Auras)
		{
			// Check if V is Object
			if (!V.IsValid() || V->Type != EJson::Object)
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Invalid '%s' field in %s"), *Key, *Filename);
				return false;
			}

			// Check if V is valid Object
			TSharedPtr<FJsonObject> AuraObj = V->AsObject();
			if (!AuraObj.IsValid())
			{
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Invalid '%s' field in %s"), *Key, *Filename);
				return false;
			}

			// Targets
			const TArray<TSharedPtr<FJsonValue>>* Targets;
			if (AuraObj->TryGetArrayField(TEXT("targets"), Targets) && Targets) {
				for (const TSharedPtr<FJsonValue>& VT : *Targets)
				{
					// Check if V is Object
					if (!VT.IsValid() || VT->Type != EJson::Object)
					{
						R.bOK = false;
						R.ErrorMsg = FString::Printf(TEXT("Invalid field in 'targets' in %s"), *Filename);
						return false;
					}

					// Check if V is valid Object
					TSharedPtr<FJsonObject> TargetObj = VT->AsObject();
					if (!TargetObj.IsValid())
					{
						R.bOK = false;
						R.ErrorMsg = FString::Printf(TEXT("Invalid field in 'targets' in %s"), *Filename);
						return false;
					}

					FString Type;
					if (!TargetObj->TryGetStringField(TEXT("type"), Type))
					{
						R.bOK = false;
						R.ErrorMsg = FString::Printf(TEXT("Missing field 'type' in %s"), *Filename);
						return false;
					}

					const TArray<TSharedPtr<FJsonValue>>* Destinations;
					if (TargetObj->TryGetArrayField(TEXT("destination"), Destinations))
					{
						for (const TSharedPtr<FJsonValue>& VD : *Destinations)
						{
							FString Dest = VD->AsString();

							// TODO: validate type and destination

							EAuraType AuraType;
							if (!MovementManager::TryParseAuraType(Type, AuraType)) {
								R.bOK = false;
								R.ErrorMsg = FString::Printf(TEXT("Invalid aura type %s in %s"), *Type, *Filename);
								return false;
							}

							if (InMap.Contains(AuraType)) {
								InMap[AuraType].Add(Dest);
							}
							else {
								InMap.Add(AuraType, { Dest });
							}
						}
					}
					else {
						R.bOK = false;
						R.ErrorMsg = FString::Printf(TEXT("Missing field 'destination' in %s"), *Filename);
						return false;
					}
				}
			}
			else {
				R.bOK = false;
				R.ErrorMsg = FString::Printf(TEXT("Missing field 'targets' in %s"), *Filename);
				return false;
			}
		}
	} // May be no aura, so no else

	return true;
}

static EImageFormat DetectImageFormat(const FString& FilePath)
{
	const FString Ext = FPaths::GetExtension(FilePath).ToLower();
	if (Ext == TEXT("png")) return EImageFormat::PNG;
	if (Ext == TEXT("jpg") || Ext == TEXT("jpeg")) return EImageFormat::JPEG;
	if (Ext == TEXT("bmp")) return EImageFormat::BMP;
	if (Ext == TEXT("tga")) return EImageFormat::TGA;
	return EImageFormat::Invalid;
}

UTexture2D* ChessLoader::LoadTexture2DFromFile(const FString& FilePath)
{
	TArray<uint8> CompressedData;
	if (!FFileHelper::LoadFileToArray(CompressedData, *FilePath) || CompressedData.Num() == 0)
	{
		return nullptr;
	}

	const EImageFormat Format = DetectImageFormat(FilePath);
	if (Format == EImageFormat::Invalid)
	{
		return nullptr;
	}

	IImageWrapperModule& ImageWrapperModule =
		FModuleManager::LoadModuleChecked<IImageWrapperModule>(TEXT("ImageWrapper"));

	TSharedPtr<IImageWrapper> ImageWrapper = ImageWrapperModule.CreateImageWrapper(Format);
	if (!ImageWrapper.IsValid() || !ImageWrapper->SetCompressed(CompressedData.GetData(), CompressedData.Num()))
	{
		return nullptr;
	}

	// Decode to BGRA8 (UE-friendly)
	TArray<uint8> RawBGRA;
	if (!ImageWrapper->GetRaw(ERGBFormat::BGRA, 8, RawBGRA))
	{
		return nullptr;
	}

	const int32 Width = ImageWrapper->GetWidth();
	const int32 Height = ImageWrapper->GetHeight();

	UTexture2D* Tex = UTexture2D::CreateTransient(Width, Height, PF_B8G8R8A8);
	if (!Tex)
	{
		return nullptr;
	}

	Tex->SRGB = true;               // typical for color images
	Tex->MipGenSettings = TMGS_NoMipmaps; // optional: no mipmaps for UI
	Tex->NeverStream = true;        // optional: keep in memory

	// Copy pixels into the texture
	void* TextureData = Tex->GetPlatformData()->Mips[0].BulkData.Lock(LOCK_READ_WRITE);
	FMemory::Memcpy(TextureData, RawBGRA.GetData(), RawBGRA.Num());
	Tex->GetPlatformData()->Mips[0].BulkData.Unlock();

	Tex->UpdateResource();
	return Tex;
}