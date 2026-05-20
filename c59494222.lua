--墓守の刻印
-- 效果：
-- ①：自己主要阶段1开始时才能发动。从以下效果选1个直到对方回合结束时适用。
-- ●双方不能把墓地的卡的效果发动。
-- ●双方不能把墓地的卡除外。
-- ●双方不能把墓地的怪兽特殊召唤。
function c59494222.initial_effect(c)
	-- ①：自己主要阶段1开始时才能发动。从以下效果选1个直到对方回合结束时适用。●双方不能把墓地的卡的效果发动。●双方不能把墓地的卡除外。●双方不能把墓地的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c59494222.condition)
	e1:SetOperation(c59494222.activate)
	c:RegisterEffect(e1)
end
-- 设置卡片发动的条件：必须在主要阶段1开始时
function c59494222.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1，且玩家在当前阶段尚未进行任何操作（即阶段开始时）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 效果处理：让玩家选择一个效果适用，并注册对应的全局限制效果，直到对方回合结束
function c59494222.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让发动玩家从三个效果中选择一个适用
	local op=Duel.SelectOption(tp,aux.Stringid(59494222,0),aux.Stringid(59494222,1),aux.Stringid(59494222,2))  --"双方不能把墓地的卡的效果发动/双方不能把墓地的卡除外/双方不能把墓地的怪兽特殊召唤"
	-- 从以下效果选1个直到对方回合结束时适用。●双方不能把墓地的卡的效果发动。●双方不能把墓地的卡除外。●双方不能把墓地的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,1)
	if op==0 then
		e1:SetDescription(aux.Stringid(59494222,0))  --"双方不能把墓地的卡的效果发动"
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetValue(c59494222.actlimit)
	elseif op==1 then
		e1:SetDescription(aux.Stringid(59494222,1))  --"双方不能把墓地的卡除外"
		e1:SetCode(EFFECT_CANNOT_REMOVE)
		e1:SetTarget(c59494222.rmlimit)
	else
		e1:SetDescription(aux.Stringid(59494222,2))  --"双方不能把墓地的怪兽特殊召唤"
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTarget(c59494222.splimit)
	end
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将限制效果注册给玩家，使其在全局生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的卡片位置：判断发动效果的卡片是否在墓地
function c59494222.actlimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
-- 限制除外的卡片位置：判断被除外的卡片是否在墓地
function c59494222.rmlimit(e,c)
	return c:IsLocation(LOCATION_GRAVE)
end
-- 限制特殊召唤的怪兽：判断被特殊召唤的怪兽是否在墓地
function c59494222.splimit(e,c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
