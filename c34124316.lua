--サイバーポッド
-- 效果：
-- ①：这张卡反转的场合发动。场上的怪兽全部破坏。那之后，双方从卡组上面把5张卡翻开，那之中的4星以下而可以特殊召唤的怪兽全部表侧攻击表示或里侧守备表示特殊召唤。剩下的翻开的卡全部加入手卡。
function c34124316.initial_effect(c)
	-- ①：这张卡反转的场合发动。场上的怪兽全部破坏。那之后，双方从卡组上面把5张卡翻开，那之中的4星以下而可以特殊召唤的怪兽全部表侧攻击表示或里侧守备表示特殊召唤。剩下的翻开的卡全部加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c34124316.target)
	e1:SetOperation(c34124316.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置连锁处理时的破坏效果目标为场上的所有怪兽
function c34124316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索满足条件的场上怪兽组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为破坏效果，目标为场上所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①：这张卡反转的场合发动。场上的怪兽全部破坏。那之后，双方从卡组上面把5张卡翻开，那之中的4星以下而可以特殊召唤的怪兽全部表侧攻击表示或里侧守备表示特殊召唤。剩下的翻开的卡全部加入手卡。
function c34124316.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的场上怪兽组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将场上所有怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取玩家从卡组上方翻开的5张卡
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方从卡组上方翻开的5张卡
	local g2=Duel.GetDecktopGroup(1-tp,5)
	local hg=Group.CreateGroup()
	local gg=Group.CreateGroup()
	-- 确认玩家卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	local tc=g1:GetFirst()
	while tc do
		if tc:IsLevelBelow(4) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
			-- 禁止接下来的操作进行洗切卡组检测
			Duel.DisableShuffleCheck()
			-- 将满足条件的4星以下怪兽特殊召唤至玩家场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif tc:IsAbleToHand() then
			hg:AddCard(tc)
		else gg:AddCard(tc) end
		tc=g1:GetNext()
	end
	-- 确认对方卡组最上方的5张卡
	Duel.ConfirmDecktop(1-tp,5)
	tc=g2:GetFirst()
	while tc do
		if tc:IsLevelBelow(4) and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
			-- 禁止接下来的操作进行洗切卡组检测
			Duel.DisableShuffleCheck()
			-- 将满足条件的4星以下怪兽特殊召唤至对方场上
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif tc:IsAbleToHand() then
			hg:AddCard(tc)
		else gg:AddCard(tc) end
		tc=g2:GetNext()
	end
	if hg:GetCount()>0 then
		-- 禁止接下来的操作进行洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 将满足条件的卡加入玩家手牌
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		-- 手动洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 手动洗切对方手牌
		Duel.ShuffleHand(1-tp)
	end
	if gg:GetCount()>0 then
		-- 禁止接下来的操作进行洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 将不满足特殊召唤条件的卡送去墓地
		Duel.SendtoGrave(gg,REASON_EFFECT)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
