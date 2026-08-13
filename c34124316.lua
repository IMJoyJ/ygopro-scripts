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
-- 效果发动时的条件检查与操作信息登记：发动时无额外条件（chk==0即返回true），同时检索场上所有怪兽，并将本次效果预定破坏的对象和数量（全场怪兽）写入连锁操作信息。
function c34124316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上全部怪兽（包括主要怪兽区和额外怪兽区），用于后续的破坏判定。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本连锁的破坏效果以全场怪兽为对象，数量为对象怪兽数，用于给其他卡（如星尘龙等）提供发动检测信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理整体流程：先破坏场上所有怪兽；随后双方各自翻开卡组顶5张，分别对每张卡判断：4星以下且可特殊召唤则特殊召唤；否则若能加入手卡则加入手卡；否则送去墓地；最后完成所有特殊召唤并洗牌。
function c34124316.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有怪兽作为即将被破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将获取到的场上所有怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取发动玩家（tp）卡组最上方的5张卡，用于后续翻开处理。
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方玩家（1-tp）卡组最上方的5张卡，用于后续翻开处理。
	local g2=Duel.GetDecktopGroup(1-tp,5)
	local hg=Group.CreateGroup()
	local gg=Group.CreateGroup()
	-- 确认（向双方展示）发动玩家卡组最上方5张卡。
	Duel.ConfirmDecktop(tp,5)
	local tc=g1:GetFirst()
	while tc do
		if tc:IsLevelBelow(4) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
			-- 禁用自动洗切检查，避免接下来从卡组顶特殊召唤或移动卡后系统自动洗切卡组。
			Duel.DisableShuffleCheck()
			-- 将发动玩家翻开的满足条件（4星以下且可特殊召唤）的怪兽，以表侧攻击表示或里侧守备表示特殊召唤到发动玩家场上，作为连续特殊召唤的一步。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif tc:IsAbleToHand() then
			hg:AddCard(tc)
		else gg:AddCard(tc) end
		tc=g1:GetNext()
	end
	-- 确认（向双方展示）对方玩家卡组最上方5张卡。
	Duel.ConfirmDecktop(1-tp,5)
	tc=g2:GetFirst()
	while tc do
		if tc:IsLevelBelow(4) and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
			-- 禁用自动洗切检查，避免对方从卡组特殊召唤或移动卡后系统自动洗切卡组。
			Duel.DisableShuffleCheck()
			-- 将对方玩家翻开的满足条件（4星以下且可特殊召唤）的怪兽，以表侧攻击表示或里侧守备表示特殊召唤到对方玩家场上，作为连续特殊召唤的一步。
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif tc:IsAbleToHand() then
			hg:AddCard(tc)
		else gg:AddCard(tc) end
		tc=g2:GetNext()
	end
	if hg:GetCount()>0 then
		-- 在将剩余卡加入手卡或送去墓地前禁用自动洗切检查。
		Duel.DisableShuffleCheck()
		-- 将剩下的可以加入手卡的卡全部加入其持有者的手卡（nil表示加入原持有者）。
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		-- 洗切发动玩家的手卡，因为可能有卡加入了手卡。
		Duel.ShuffleHand(tp)
		-- 洗切对方玩家的手卡，因为可能有卡加入了对方手卡。
		Duel.ShuffleHand(1-tp)
	end
	if gg:GetCount()>0 then
		-- 在将剩余不能加入手卡的卡送去墓地前禁用自动洗切检查。
		Duel.DisableShuffleCheck()
		-- 将既不能特殊召唤也不能加入手卡的剩余翻开卡，以效果原因送去墓地。
		Duel.SendtoGrave(gg,REASON_EFFECT)
	end
	-- 结束连续特殊召唤处理，统一完成所有通过SpecialSummonStep进行的特殊召唤。
	Duel.SpecialSummonComplete()
end
