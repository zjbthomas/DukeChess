// Fill out your copyright notice in the Description page of Project Settings.


#include "LoadingUserWidget.h"

#include "GUIPlayerController.h"

void ULoadingUserWidget::SetMessage(FString Message)
{

	if (TextLoadingMsg)
	{
		TextLoadingMsg->SetText(FText::FromString(Message));
	}
}

void ULoadingUserWidget::SetProgress(int32 Percentage)
{

	if (TextLoading)
	{
		const FText Num = FText::AsNumber(Percentage);
		TextLoading->SetText(FText::Format(FText::FromString(TEXT("{0} %")), Num));
	}
}

void ULoadingUserWidget::NativeConstruct()
{
	Super::NativeConstruct();

	if (APlayerController* PC = GetOwningPlayer())
	{
		if (AGUIPlayerController* GUIPC = Cast<AGUIPlayerController>(PC))
		{
			GUIPC->RegisterLoadingUserWidget(this);
		}
	}
}