// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "IMovementBase.h"
#include "Move.h"

enum EMovementType : uint8 { MOVE, JUMP, SLIDE, JUMPSLIDE, STRIKE, COMMAND, SUMMON };
enum EAuraType : uint8 { DEFENSE };

/**
 * 
 */
class DUKECHESS_API MovementManager
{
public:
	static MovementManager& getMovementManager() {
		static MovementManager instance;
		return instance;
	}

	TMap<EMovementType, IMovementBase*> MovementInsts = {
		{EMovementType::MOVE, &DukeChess::Move::getMovement()}
	};

	static bool TryParseMovementType(const FString& Str, EMovementType& OutType)
	{
		const FName Name(*Str);

		if (Name == TEXT("Move")) { OutType = EMovementType::MOVE; return true; }
		if (Name == TEXT("Jump")) { OutType = EMovementType::JUMP; return true; }
		if (Name == TEXT("Slide")) { OutType = EMovementType::SLIDE; return true; }
		if (Name == TEXT("JumpSlide")) { OutType = EMovementType::JUMPSLIDE; return true; }
		if (Name == TEXT("Strike")) { OutType = EMovementType::STRIKE; return true; }
		if (Name == TEXT("Command")) { OutType = EMovementType::COMMAND; return true; }
		if (Name == TEXT("Summon")) { OutType = EMovementType::SUMMON; return true; }

		return false;
	}

	static bool TryParseAuraType(const FString& Str, EAuraType& OutType)
	{
		const FName Name(*Str);

		if (Name == TEXT("Defense")) { OutType = EAuraType::DEFENSE; return true; }

		return false;
	}

private:
	MovementManager() = default;

	// Delete copy constructor and assignment operator to prevent copying
	MovementManager(const MovementManager&) = delete;
	MovementManager& operator=(const MovementManager&) = delete;
};
