--ウィングド・ライノ
-- 效果：
-- 陷阱卡发动时可以发动。场上表侧表示存在的这张卡回到持有者手卡。
function c18430390.initial_effect(c)
	-- 陷阱卡发动时可以发动。场上表侧表示存在的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(18430390,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18430390.condition)
	e1:SetTarget(c18430390.target)
	e1:SetOperation(c18430390.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时，连锁的卡必须是陷阱卡的发动效果
function c18430390.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetOwner():IsType(TYPE_TRAP)
end
-- 效果处理时，确认这张卡可以送入手牌
function c18430390.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息，将此卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理时，确认此卡与效果有关联，然后将其送入手牌
function c18430390.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因送入持有者手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
