// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

/**
 * 
 */
class DUKECHESS_API IMovementBase
{
public:
	virtual ~IMovementBase() = default;

	virtual TArray<int32> ValidateMovement() = 0;
	virtual TArray<int32> ValidateControlArea() = 0;
};
