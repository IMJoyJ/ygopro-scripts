--D-HERO ディパーテッドガイ
-- 效果：
-- 自己的准备阶段时，这张卡在墓地存在的场合，在对方场上表侧攻击表示特殊召唤。这张卡被战斗破坏的场合，不去墓地从游戏中除外。这张卡从手卡·卡组被卡的效果送去墓地的场合，不去墓地从游戏中除外。
function c39829561.initial_effect(c)
	-- 效果原文：自己的准备阶段时，这张卡在墓地存在的场合，在对方场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39829561,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c39829561.condition)
	e1:SetTarget(c39829561.target)
	e1:SetOperation(c39829561.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡被战斗破坏的场合，不去墓地从游戏中除外。这张卡从手卡·卡组被卡的效果送去墓地的场合，不去墓地从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c39829561.recon)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在特定怪兽（命运英雄 暗影人）
function c39829561.filter(c)
	return c:IsFaceup() and c:IsCode(83986578)
end
-- 规则层面：判断是否为当前回合玩家的准备阶段且场上没有特定怪兽
function c39829561.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家的准备阶段且场上没有特定怪兽
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c39829561.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置特殊召唤的连锁操作信息
function c39829561.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的连锁操作信息，指定目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将自身从墓地特殊召唤到对方场上
function c39829561.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧攻击表示特殊召唤到对方场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 判断该卡是否因战斗破坏或因效果送入墓地
function c39829561.recon(e)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE))
		or (c:IsLocation(LOCATION_DECK+LOCATION_HAND) and c:IsReason(REASON_EFFECT))
end
