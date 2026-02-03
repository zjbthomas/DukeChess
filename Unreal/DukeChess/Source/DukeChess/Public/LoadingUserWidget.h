// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "Components/TextBlock.h"

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "LoadingUserWidget.generated.h"

/**
 * 
 */
UCLASS()
class DUKECHESS_API ULoadingUserWidget : public UUserWidget
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable)
	void SetMessage(FString Message);

	UFUNCTION(BlueprintCallable)
	void SetProgress(int32 Percentage);

protected:
	UPROPERTY(meta = (BindWidget))
	UTextBlock* TextLoadingMsg;

	UPROPERTY(meta = (BindWidget))
	UTextBlock* TextLoading;

	virtual void NativeConstruct() override;
};
