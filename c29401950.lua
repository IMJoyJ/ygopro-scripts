--奈落の落とし穴
-- 效果：
-- ①：对方把攻击力1500以上的怪兽召唤·反转召唤·特殊召唤时才能发动。那些攻击力1500以上的怪兽破坏并除外。
function c29401950.initial_effect(c)
	-- ①：对方把攻击力1500以上的怪兽召唤·反转召唤·特殊召唤时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c29401950.target)
	e1:SetOperation(c29401950.activate)
	c:RegisterEffect(e1)
	-- ①：对方把攻击力1500以上的怪兽召唤·反转召唤·特殊召唤时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c29401950.target)
	e2:SetOperation(c29401950.activate)
	c:RegisterEffect(e2)
	-- ①：对方把攻击力1500以上的怪兽召唤·反转召唤·特殊召唤时才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c29401950.target2)
	e3:SetOperation(c29401950.activate2)
	c:RegisterEffect(e3)
end
-- 筛选满足条件的怪兽：在主要怪兽区、表侧表示、攻击力不低于1500、不是发动玩家、可以除外
function c29401950.filter(c,tp,ep)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetAttack()>=1500
		and ep~=tp and c:IsAbleToRemove()
end
-- 判断是否满足发动条件并设置操作信息：若满足条件则设置目标卡和破坏、除外的操作信息
function c29401950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return c29401950.filter(tc,tp,ep) end
	-- 设置连锁处理的目标卡为eg
	Duel.SetTargetCard(eg)
	-- 设置操作信息为破坏效果，目标为tc，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置操作信息为除外效果，目标为tc，数量为1
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 处理效果发动：若目标卡满足条件则将其破坏并除外
function c29401950.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>=1500 then
		-- 执行破坏并除外操作，原因REASON_EFFECT，去LOCATION_REMOVED位置
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
-- 筛选满足条件的怪兽：在主要怪兽区、表侧表示、攻击力不低于1500、是对方召唤、可以除外
function c29401950.filter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetAttack()>=1500 and c:IsSummonPlayer(1-tp)
		and c:IsAbleToRemove()
end
-- 判断是否满足发动条件并设置操作信息：若满足条件则设置目标卡和破坏、除外的操作信息
function c29401950.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c29401950.filter2,1,nil,tp) end
	local g=eg:Filter(c29401950.filter2,nil,tp)
	-- 设置连锁处理的目标卡为eg
	Duel.SetTargetCard(eg)
	-- 设置操作信息为破坏效果，目标为g，数量为g的张数
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息为除外效果，目标为g，数量为g的张数
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 筛选满足条件的怪兽：表侧表示、攻击力不低于1500、是对方召唤、与效果相关、在主要怪兽区
function c29401950.filter3(c,e,tp)
	return c:IsFaceup() and c:GetAttack()>=1500 and c:IsSummonPlayer(1-tp)
		and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
end
-- 处理效果发动：筛选满足条件的怪兽组并执行破坏和除外操作
function c29401950.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c29401950.filter3,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行破坏并除外操作，原因REASON_EFFECT，去LOCATION_REMOVED位置
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
