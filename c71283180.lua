--トルネード・バード
-- 效果：
-- 反转：场上的魔法·陷阱卡2张回主人的手卡。
function c71283180.initial_effect(c)
	-- 反转：场上的魔法·陷阱卡2张回主人的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71283180,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c71283180.target)
	e1:SetOperation(c71283180.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上可以成为效果对象且能回到手牌的魔法、陷阱卡
function c71283180.filter(c,e)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 效果发动的对象选择：必须选择场上2张魔法·陷阱卡为对象，若不足2张则不进行选择
function c71283180.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c71283180.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取双方场上所有满足过滤条件的魔法、陷阱卡
	local g=Duel.GetMatchingGroup(c71283180.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if g:GetCount()<2 then
		g:Clear()
		-- 若场上可选择的卡不足2张，则将空卡片组设为效果对象（导致后续效果不处理）
		Duel.SetTargetCard(g)
		return
	end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将玩家选择的2张卡片设为当前连锁的效果对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示该连锁的处理为将选中的2张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,2,0,0)
end
-- 效果处理：将成为对象的2张卡送回持有者的手牌
function c71283180.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg then return end
	local dg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if dg:GetCount()==2 then
		-- 通过效果将这些卡送回持有者的手牌
		Duel.SendtoHand(dg,nil,REASON_EFFECT)
	end
end
