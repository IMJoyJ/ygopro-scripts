--サイバーポッド
-- 效果：
-- ①：这张卡反转的场合发动。场上的怪兽全部破坏。那之后，双方从卡组上面把5张卡翻开，那之中的4星以下而可以特殊召唤的怪兽全部表侧攻击表示或里侧守备表示特殊召唤。剩下的翻开的卡全部加入手卡。
function c34124316.initial_effect(c)
	-- ①：这张卡反转的场合发动。场上的怪兽全部破坏。那之后，双方从卡组上面把5张卡翻开，那之中的4星以下而可以特殊召唤的怪兽全部表侧攻击表示或里侧守备表示特殊召唤。剩下的翻开的卡全部加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c34124316.target)
	e1:SetOperation(c34124316.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的Target函数：在发动时始终通过检测，获取双方场上的全部怪兽并设置破坏操作信息
function c34124316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方怪兽区上的全部怪兽卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置将场上全部怪兽破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 反转效果的Operation函数：破坏场上所有怪兽后，双方各翻开卡组最上方5张卡，将4星以下可特召的怪兽以表侧攻击或里侧守备表示特召，其余可回手的卡加入手卡（无法回手的送入墓地）
function c34124316.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方怪兽区上的全部怪兽卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果破坏双方场上的全部怪兽
	Duel.Destroy(g,REASON_EFFECT)
	-- 获取己方卡组最上方的5张卡
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方卡组最上方的5张卡
	local g2=Duel.GetDecktopGroup(1-tp,5)
	local hg=Group.CreateGroup()
	local gg=Group.CreateGroup()
	-- 翻开并确认己方卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	local tc=g1:GetFirst()
	while tc do
		if tc:IsLevelBelow(4) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
			-- 禁用紧接着的己方分步特殊召唤后的自动洗切卡组检测
			Duel.DisableShuffleCheck()
			-- 将符合条件的4星以下己方怪兽以表侧攻击表示或里侧守备表示分步特殊召唤到己方场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif tc:IsAbleToHand() then
			hg:AddCard(tc)
		else gg:AddCard(tc) end
		tc=g1:GetNext()
	end
	-- 翻开并确认对方卡组最上方的5张卡
	Duel.ConfirmDecktop(1-tp,5)
	tc=g2:GetFirst()
	while tc do
		if tc:IsLevelBelow(4) and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
			-- 禁用紧接着的对方分步特殊召唤后的自动洗切卡组检测
			Duel.DisableShuffleCheck()
			-- 将符合条件的4星以下对方怪兽以表侧攻击表示或里侧守备表示分步特殊召唤到对方场上
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
		elseif tc:IsAbleToHand() then
			hg:AddCard(tc)
		else gg:AddCard(tc) end
		tc=g2:GetNext()
	end
	if hg:GetCount()>0 then
		-- 禁用将剩余卡片加入手卡前的自动洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 以效果将双方剩下的可加入手卡的翻开卡片分别加入各自持有者的手卡
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		-- 手动洗切己方玩家的手卡
		Duel.ShuffleHand(tp)
		-- 手动洗切对方玩家的手卡
		Duel.ShuffleHand(1-tp)
	end
	if gg:GetCount()>0 then
		-- 禁用将无法加入手卡也无法特召的卡片送墓前的自动洗切卡组检测
		Duel.DisableShuffleCheck()
		-- 将因规则或效果限制既不能特殊召唤也不能加入手卡的剩余翻开卡以效果送去墓地
		Duel.SendtoGrave(gg,REASON_EFFECT)
	end
	-- 统一完成双方所有分步特殊召唤流程并触发相关时点
	Duel.SpecialSummonComplete()
end
