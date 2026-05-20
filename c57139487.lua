--連鎖除外
-- 效果：
-- 攻击力1000以下的怪兽召唤·反转召唤·特殊召唤成功时才能发动。那些攻击力1000以下的怪兽从游戏中除外，再把和除外的卡同名卡从对方的手卡·卡组全部除外。
function c57139487.initial_effect(c)
	-- 攻击力1000以下的怪兽召唤·反转召唤·特殊召唤成功时才能发动。那些攻击力1000以下的怪兽从游戏中除外，再把和除外的卡同名卡从对方的手卡·卡组全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c57139487.target)
	e1:SetOperation(c57139487.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤出场上表侧表示、攻击力1000以下且可以被除外的怪兽
function c57139487.filter(c)
	return c:IsFaceup() and c:GetAttack()<=1000 and c:IsAbleToRemove()
end
-- 发动的准备：检查是否存在满足条件的被召唤怪兽，将其设为效果对象，并设置除外的操作信息
function c57139487.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c57139487.filter,1,nil) end
	local g=eg:Filter(c57139487.filter,nil)
	-- 将本次召唤的满足条件的怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置除外操作的信息，包含要除外的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 过滤出在效果处理时仍表侧表示、攻击力在1000以下且仍与本效果相关的对象怪兽
function c57139487.efilter(c,e)
	return c:IsFaceup() and c:IsAttackBelow(1000) and c:IsRelateToEffect(e)
end
-- 效果处理：除外目标怪兽，并检索对方手牌和卡组中同名的卡全部除外
function c57139487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为对象的怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c57139487.efilter,nil,e)
	-- 将满足条件的对象怪兽表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	local rg=Group.CreateGroup()
	local tc=sg:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_REMOVED) then
			local tpe=tc:GetType()
			if bit.band(tpe,TYPE_TOKEN)==0 then
				-- 检索对方手卡和卡组中与被除外怪兽同名的卡片组
				local g1=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK+LOCATION_HAND,nil,tc:GetCode())
				rg:Merge(g1)
			end
		end
		tc=sg:GetNext()
	end
	if rg:GetCount()>0 then
		-- 中断当前效果，使后续的除外处理与前面的除外处理不视为同时进行
		Duel.BreakEffect()
		-- 将对方手卡和卡组中的同名卡全部表侧表示除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
