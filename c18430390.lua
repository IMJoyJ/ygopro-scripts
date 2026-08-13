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
-- 判定本次发动是否为陷阱卡的卡的发动：若连锁中发动的效果是魔法陷阱卡的发动（EFFECT_TYPE_ACTIVATE）且该卡类型为陷阱卡，则满足“陷阱卡发动时”的触发条件。
function c18430390.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetOwner():IsType(TYPE_TRAP)
end
-- 效果发动的合法性检查与操作信息设置：当此卡能够回到手卡时才允许发动，并登记将这张卡加入手卡的效果信息。
function c18430390.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 向系统登记本连锁的处理信息：将当前效果的操作声明为把这张卡加入持有者手卡，数量为1，用于后续其他效果的发动检测与记录。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理时的实际操作：判断此卡仍与效果保持关联（未被无效或离场导致联系重置）时，将其返回持有者手卡。
function c18430390.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因将这张卡送去其持有者的手卡，实现“回到手卡”这一最终操作。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
