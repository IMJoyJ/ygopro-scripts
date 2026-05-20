--CNo.106 溶岩掌ジャイアント・ハンド・レッド
-- 效果：
-- 5星怪兽×3
-- ①：这张卡有「No.」怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，魔法·陷阱·怪兽的效果在场上发动时发动。这张卡1个超量素材取除，这张卡以外的场上的全部表侧表示的卡的效果直到回合结束时无效化。
function c55888045.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽×3。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：这张卡有「No.」怪兽在作为超量素材的场合，得到以下效果。●1回合1次，魔法·陷阱·怪兽的效果在场上发动时发动。这张卡1个超量素材取除，这张卡以外的场上的全部表侧表示的卡的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55888045,0))  --"效果无效"
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c55888045.negcon)
	e1:SetOperation(c55888045.negop)
	c:RegisterEffect(e1)
end
-- 设定该卡的「No.」编号为106。
aux.xyz_number[55888045]=106
-- 判断是否满足发动条件：魔法·陷阱·怪兽的效果在场上发动，且这张卡有「No.」怪兽在作为超量素材。
function c55888045.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中发动效果的卡片所在的位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0 and not e:GetHandler():IsStatus(STATUS_CHAINING)
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x48)
end
-- 过滤场上表侧表示的魔法·陷阱卡或效果怪兽。
function c55888045.filter(c)
	return c:IsFaceup() and (c:IsLocation(LOCATION_SZONE) or c:IsType(TYPE_EFFECT))
end
-- 效果处理：取除1个超量素材，将这张卡以外的场上全部表侧表示的卡的效果直到回合结束时无效。
function c55888045.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在场、是否为直接连锁，并取除1个超量素材。
	if not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 or not c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then return end
	-- 获取场上除这张卡以外的所有表侧表示的卡片。
	local g=Duel.GetMatchingGroup(c55888045.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		-- 这张卡以外的场上的全部表侧表示的卡的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这张卡以外的场上的全部表侧表示的卡的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
