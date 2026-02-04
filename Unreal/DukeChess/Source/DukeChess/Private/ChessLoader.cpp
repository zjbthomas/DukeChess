// Fill out your copyright notice in the Description page of Project Settings.


#include "ChessLoader.h"

// For JSON
#include "Misc/FileHelper.h"
#include "Serialization/JsonReader.h"
#include "Serialization/JsonSerializer.h"
#include "Dom/JsonObject.h"

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
			// TODO: handle chess_amount
			continue;
		}

		FString Filename = CONTENTCHESSPATH / E.JSONRelPath;

		FString JsonText;
		if (!FFileHelper::LoadFileToString(JsonText, *Filename))
		{
			R.bOK = false;
			R.ErrorMsg = FString::Printf(TEXT("Failed to read json: %s"),*Filename);
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

		// TODO: Load image

		// Add chess to list
		ChessNameArray.Add(Name);
		ChessModelMap.Add(Name, Chess);
	}

	return true;
}

bool ChessLoader::LoadChessFromSaved(LoadChessResult& R) {

	return true;

	/*var used_dir = USERCHESSDIR if (Global.is_local and not Global.is_ai) else RESCHESSDIR
		var chess_amount_file = CHESSAMOUNTJSON if (Global.is_local and not Global.is_ai) else CHESSAMOUNTJSONONLINE

		var chess_dir = DirAccess.open(used_dir)

		for chess_name in chess_dir.get_directories() :
			# load XML
			var xml_path = used_dir + "/" + chess_name + "/" + chess_name + ".xml" # XML has the same name as the folder
			if not FileAccess.file_exists(xml_path) :
				error_message.emit(tr("CHESS_LOADER_ERROR_XML_NOT_EXISTS") % [xml_path])
				return

				var xml_root = XML.parse_file(xml_path).root

				# check name and version
				var name = xml_root.attributes["name"]
				if (name != chess_name) :
					error_message.emit(tr("CHESS_LOADER_ERROR_DISMATCH_NAME") % [xml_path])
					return

					# TODO : length of name should not be too long
					if (name.length() > 12) :
						error_message.emit(tr("CHESS_LOADER_ERROR_LONG_NAME") % [name])
						return

						var version = int(xml_root.attributes["version"])

						var chess = ChessModel.new()

						chess.name = name
						chess.version = version

						# locale names
						for locale in Global.LOCALES:
	# default locale name
		chess.tr_name_dict[locale] = chess.name

		if (xml_root.get("localization") != null) :
			if (xml_root.localization.get(locale) != null) :
				chess.tr_name_dict[locale] = xml_root.localization.get(locale).content

				# center offsets
				if (xml_root.front.get('center') != null) :
					var front_center_offset_x = Global.dest_to_offsets_for_chess(xml_root.front.center.content)[0]
					var front_center_offset_y = Global.dest_to_offsets_for_chess(xml_root.front.center.content)[1]

					chess.front_center_offset_x = front_center_offset_x
					chess.front_center_offset_y = front_center_offset_y

					if (xml_root.back.get('center') != null) :
						var back_center_offset_x = Global.dest_to_offsets_for_chess(xml_root.back.center.content)[0]
						var back_center_offset_y = Global.dest_to_offsets_for_chess(xml_root.back.center.content)[1]

						chess.back_center_offset_x = back_center_offset_x
						chess.back_center_offset_y = back_center_offset_y

						# front actions and movements
						for xml_movement in xml_root.front.movements.children:
	var ret = _parse_xml_root(xml_path, xml_movement)
		if (ret == null) :
			return

			chess.front_dict[ret[0]] = ret[1]

			# back actions and movements
			for xml_movement in xml_root.back.movements.children:
	var ret = _parse_xml_root(xml_path, xml_movement)
		if (ret == null) :
			return

			chess.back_dict[ret[0]] = ret[1]

			# front auras
			if xml_root.front.get("auras") and xml_root.front.auras.get("aura") :
				chess.front_aura_dict = _parse_xml_auras(xml_path, xml_root.front.auras.aura)

				# back auras
				if xml_root.back.get("auras") and xml_root.back.auras.get("aura") :
					chess.back_aura_dict = _parse_xml_auras(xml_path, xml_root.back.auras.aura)

					# load image
					var image_path = used_dir + "/" + chess_name + "/" + chess_name + ".png" # TODO: only PNG is allowed; it has the same name as the folder
					if (Global.is_local and not Global.is_ai) :
						if (FileAccess.file_exists(image_path)) :
							chess.image = ImageTexture.create_from_image(Image.load_from_file(image_path))
						else :
							chess.image = load(image_path)

							# add chess to list
							chess_name_list.append(chess_name)
							chessmodel_dict[chess_name] = chess

							# set default chess num from JSON
							var json_as_text = FileAccess.get_file_as_string(used_dir + "/" + chess_amount_file)
							var json_as_dict = JSON.parse_string(json_as_text)
							if not json_as_dict:
	error_message.emit(tr("CHESS_LOADER_ERROR_PARSE_JSON") % [used_dir + "/" + chess_amount_file])
		return

		for chess_name in chess_name_list :
	var amount_str = json_as_dict.get(chess_name)

		var amount = 0
		if amount_str :
			amount = int(amount_str)

			# some special rules
			if (chess_name == "Duke") :
				if (amount != 1) :
					error_message.emit(tr("CHESS_LOADER_ERROR_DUKE_AMOUNT") % [amount, used_dir + "/" + chess_amount_file])
					return

					if (chess_name == "Footman") :
						if (amount < 2) :
							error_message.emit(tr("CHESS_LOADER_ERROR_FOOTMAN_AMOUNT") % [amount, used_dir + "/" + chess_amount_file])
							return

							chess_max_amount_dict[chess_name] = amount*/
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