--D-HERO ディパーテッドガイ
-- 效果：
-- 自己的准备阶段时，这张卡在墓地存在的场合，在对方场上表侧攻击表示特殊召唤。这张卡被战斗破坏的场合，不去墓地从游戏中除外。这张卡从手卡·卡组被卡的效果送去墓地的场合，不去墓地从游戏中除外。
function c39829561.initial_effect(c)
	-- 自己的准备阶段时，这张卡在墓地存在的场合，在对方场上表侧攻击表示特殊召唤。
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
	-- 这张卡被战斗破坏的场合，不去墓地从游戏中除外。这张卡从手卡·卡组被卡的效果送去墓地的场合，不去墓地从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c39829561.recon)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为表侧表示且卡号为83986578（王虎）。
function c39829561.filter(c)
	return c:IsFaceup() and c:IsCode(83986578)
end
-- 发动条件：必须是由这张卡的持有者（tp）在自己的准备阶段，且场上不存在表侧表示的王虎时才能发动。
function c39829561.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回布尔值：当前回合玩家是否等于tp，并且场上不存在满足filter条件的王虎。
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(c39829561.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果发动时的目标处理：若为发动时检查（chk==0）则直接返回true允许发动，然后登记特殊召唤的操作信息。
function c39829561.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将效果持有者自身（这张卡）作为要特殊召唤的卡，数量为1，目标玩家与位置暂不指定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若这张卡仍与效果关联，则将其特殊召唤到对方场上表侧攻击表示。
function c39829561.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 实际特殊召唤：由tp玩家将这张卡以表侧攻击表示特殊召唤到对方（1-tp）的怪兽区（不跳过召唤条件与苏生限制检查）。
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 除外代替送墓的适用条件：这张卡在怪兽区域被战斗破坏，或从手卡·卡组被卡的效果送去墓地时，改为除外。
function c39829561.recon(e)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE))
		or (c:IsLocation(LOCATION_DECK+LOCATION_HAND) and c:IsReason(REASON_EFFECT))
end
