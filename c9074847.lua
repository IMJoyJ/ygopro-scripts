--大騒動
-- 效果：
-- 自己的怪兽被对方控制的卡的效果从场地回到手卡时才能发动。场上的全部怪兽回到持有者手卡。那之后，双方从手卡把回去数量的怪兽里侧守备表示特殊召唤。
function c9074847.initial_effect(c)
	-- 自己的怪兽被对方控制的卡的效果从场地回到手卡时才能发动。场上的全部怪兽回到持有者手卡。那之后，双方从手卡把回去数量的怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c9074847.condition)
	e1:SetTarget(c9074847.target)
	e1:SetOperation(c9074847.operation)
	c:RegisterEffect(e1)
end
-- 过滤回到手卡的卡是否为自己场上的怪兽
function c9074847.confilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查是否是对方卡的效果导致自己场上的怪兽回到手卡
function c9074847.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c9074847.confilter,1,nil,tp)
end
-- 过滤因该效果实际回到手卡的属于特定玩家的怪兽
function c9074847.thfilter(c,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 过滤手卡中可以里侧守备表示特殊召唤的怪兽
function c9074847.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动的目标过滤与操作信息设置
function c9074847.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只可以回到手卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有可以回到手卡的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为：将场上的怪兽全部回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数
function c9074847.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可以回到手卡的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将场上的全部怪兽回到持有者手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 中断当前效果，使后续的特殊召唤处理不与回手卡同时处理
	Duel.BreakEffect()
	-- 获取因该效果实际回到手卡的卡片组
	local og=Duel.GetOperatedGroup()
	local ct1=og:FilterCount(c9074847.thfilter,nil,tp)
	local ct2=og:FilterCount(c9074847.thfilter,nil,1-tp)
	-- 提示自己选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从手卡选择与回去数量相同的怪兽
	local g1=Duel.SelectMatchingCard(tp,c9074847.spfilter,tp,LOCATION_HAND,0,ct1,ct1,nil,e,tp)
	if g1:GetCount()>0 then
		local tc=g1:GetFirst()
		local cg1=Group.CreateGroup()
		while tc do
			if tc:IsPublic() then cg1:AddCard(tc) end
			-- 将自己选择的怪兽以里侧守备表示特殊召唤（分解步骤）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			tc=g1:GetNext()
		end
		if cg1:GetCount()>0 then
			-- 给对方确认自己特殊召唤的原本就是公开状态的怪兽
			Duel.ConfirmCards(1-tp,cg1)
		end
	end
	-- 提示对方选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让对方从手卡选择与回去数量相同的怪兽
	local g2=Duel.SelectMatchingCard(1-tp,c9074847.spfilter,1-tp,LOCATION_HAND,0,ct2,ct2,nil,e,1-tp)
	if g2:GetCount()>0 then
		local tc=g2:GetFirst()
		local cg2=Group.CreateGroup()
		while tc do
			if tc:IsPublic() then cg2:AddCard(tc) end
			-- 将对方选择的怪兽以里侧守备表示特殊召唤（分解步骤）
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			tc=g2:GetNext()
		end
		if cg2:GetCount()>0 then
			-- 给自己确认对方特殊召唤的原本就是公开状态的怪兽
			Duel.ConfirmCards(tp,cg2)
		end
	end
	-- 完成双方怪兽的特殊召唤
	Duel.SpecialSummonComplete()
end
