// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "IMovement.h"

/**
 * 
 */
namespace DukeChess
{
	class DUKECHESS_API Move : public IMovement<DukeChess::Move>
	{
		friend class IMovement<DukeChess::Move>;

	public:
		TArray<int32> ValidateMovement() override;
		TArray<int32> ValidateControlArea() override;

	private:
		DukeChess::Move() = default;

		// Delete copy constructor and assignment operator to prevent copying
		DukeChess::Move(const DukeChess::Move&) = delete;
		DukeChess::Move& operator=(const DukeChess::Move&) = delete;
	};
}
