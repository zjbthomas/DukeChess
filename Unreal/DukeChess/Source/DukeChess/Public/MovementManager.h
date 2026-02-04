// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "IMovementBase.h"
#include "Move.h"

enum EMovementType : uint8 { MOVE, JUMP, SLIDE, JUMPSLIDE, STRIKE, COMMAND, SUMMON };

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

private:
	MovementManager() = default;

	// Delete copy constructor and assignment operator to prevent copying
	MovementManager(const MovementManager&) = delete;
	MovementManager& operator=(const MovementManager&) = delete;
};
