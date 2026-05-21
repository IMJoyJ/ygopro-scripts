--暗黒プテラ
-- 效果：
-- 这张卡被战斗破坏以外的方法从场上送去墓地时，这张卡回到持有者手卡。
function c90654356.initial_effect(c)
	-- 这张卡被战斗破坏以外的方法从场上送去墓地时，这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90654356,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c90654356.condition)
	e1:SetTarget(c90654356.target)
	e1:SetOperation(c90654356.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查这张卡是否不是因战斗破坏，且之前存在于场上
function c90654356.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动的目标：作为必发效果直接确认发动，并设置将自身加入手卡的操作信息
function c90654356.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将1张自身卡片加入持有者手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡在墓地且与效果有关联，则将其送回持有者的手卡
function c90654356.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 通过效果将这张卡送回持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
