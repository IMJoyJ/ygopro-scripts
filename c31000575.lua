--徴兵令
-- 效果：
-- 检视对方卡组最上面的1张卡，如果那张卡是可以通常召唤的怪兽的场合，在自己场上特殊召唤。是其他卡的场合，那张卡加到对方的手卡。
function c31000575.initial_effect(c)
	-- 检视对方卡组最上面的1张卡，如果那张卡是可以通常召唤的怪兽的场合，在自己场上特殊召唤。是其他卡的场合，那张卡加到对方的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c31000575.target)
	e1:SetOperation(c31000575.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件检测：对方卡组有卡、自己主要怪兽区域有空位、且自己没有被元素英雄 烈焰侠或龙辉巧-右枢α的自肃效果影响，以确保后续特殊召唤不被禁止。
function c31000575.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组是否至少有1张卡，即对方卡组不为空，保证可以检视最上方的一张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)~=0
		-- 检查自己场上是否还有可用的主要怪兽区域，用于后续可能进行的特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否没有受到元素英雄 烈焰侠（63060238）的效果影响；烈焰侠的②效果发动后存在“不是融合怪兽不能特殊召唤”的自肃，若该自肃适用则不能发动征兵令。
		and not Duel.IsPlayerAffectedByEffect(tp,63060238)
		-- 检查自己是否没有受到龙辉巧-右枢α（97148796）的效果影响；右枢α的①效果发动的回合有“若非不能通常召唤的怪兽则不能特殊召唤”的自肃，若该自肃适用则不能发动征兵令。
		and not Duel.IsPlayerAffectedByEffect(tp,97148796) end
end
-- 效果处理：确认并获取对方卡组最上方的1张卡；若该卡是可通常召唤的怪兽且能够特殊召唤，则特殊召唤到己方场上；否则若该卡能加入手卡，则加入对方手卡并洗切对方手卡；若两种情况都不满足，则将该卡按规则送去墓地。
function c31000575.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方玩家确认并展示其卡组最上方的1张卡。
	Duel.ConfirmDecktop(1-tp,1)
	-- 取得对方卡组最上方的1张卡，并放入临时组对象中以备后续处理。
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsSummonableCard() and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 在特殊召唤分支中，禁止系统在本次操作结束后自动洗切卡组，因为这张卡是从卡组顶端被取出，不需要额外洗牌。
		Duel.DisableShuffleCheck()
		-- 将那张卡以表侧表示特殊召唤到发动者（tp）自己场上，完成“在自己场上特殊召唤”的效果处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif tc:IsAbleToHand() then
		-- 在加入手卡分支中，禁止系统在本次操作结束后自动洗切卡组，因为该卡是从卡组顶端取出并加入手卡，卡组剩余部分保持原顺序。
		Duel.DisableShuffleCheck()
		-- 将那张卡加入其持有者的手卡；由于player参数为nil，卡的持有者为对方，因此该卡加入对方手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切对方的手卡，以隐藏新加入手卡的卡来自卡组顶端的信息，避免暴露手牌顺序。
		Duel.ShuffleHand(1-tp)
	else
		-- 在既不能特殊召唤也不能加入手卡的兜底分支中，禁止系统在本次操作结束后自动洗切卡组。
		Duel.DisableShuffleCheck()
		-- 当目标卡无法被特殊召唤也无法加入手卡时，将该卡按规则（REASON_RULE）送去墓地作为最终处理。
		Duel.SendtoGrave(tc,REASON_RULE)
	end
end
