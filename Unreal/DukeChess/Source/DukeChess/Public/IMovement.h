// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "IMovementBase.h"

/**
 * 
 */
template <typename Derived>
class DUKECHESS_API IMovement : public IMovementBase
{
public:
	static Derived& getMovement()
	{
		static Derived instance;
		return instance;
	}
protected:
	IMovement() = default;
};
