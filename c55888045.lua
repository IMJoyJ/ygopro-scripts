--CNo.106 溶岩掌ジャイアント・ハンド・レッド
-- 效果：
-- 5星怪兽×3
-- ①：这张卡有「No.」怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，魔法·陷阱·怪兽的效果在场上发动时发动。这张卡1个超量素材取除，这张卡以外的场上的全部表侧表示的卡的效果直到回合结束时无效化。
function c55888045.initial_effect(c)
	-- 为这张卡添加超量召唤手续，需要用3只等级5的怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ●1回合1次，魔法·陷阱·怪兽的效果在场上发动时发动。这张卡1个超量素材取除，这张卡以外的场上的全部表侧表示的卡的效果直到回合结束时无效化。
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
-- 将这张卡登记为No.106，使其超量素材中的「No.」怪兽判定能够识别其编号
aux.xyz_number[55888045]=106
-- 效果的发动条件：确认诱发连锁的效果在场上发动，且这张卡的超量素材中存在「No.」怪兽
function c55888045.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该连锁的效果发动时的位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x48)
end
-- 筛选条件：表侧表示的、位于魔法·陷阱区域的卡或效果怪兽（即效果无效化的对象）
function c55888045.filter(c)
	return c:IsFaceup() and (c:IsLocation(LOCATION_SZONE) or c:IsType(TYPE_EFFECT))
end
-- 效果处理：取除1个超量素材，然后逐个将这张卡以外的场上全部表侧表示的卡的效果直到回合结束时无效化
function c55888045.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联、当前连锁未发生变化，并取除这张卡的1个超量素材，任一条件不满足则中断处理
	if not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 or not c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then return end
	-- 检索这张卡以外的双方场上全部表侧表示的魔法·陷阱区域的卡或效果怪兽
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
