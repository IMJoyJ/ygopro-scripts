--奈落の落とし穴
-- 效果：
-- ①：对方把攻击力1500以上的怪兽召唤·反转召唤·特殊召唤时才能发动。那些攻击力1500以上的怪兽破坏并除外。
function c29401950.initial_effect(c)
	-- 对方把攻击力1500以上的怪兽召唤时才能发动。那些攻击力1500以上的怪兽破坏并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c29401950.target)
	e1:SetOperation(c29401950.activate)
	c:RegisterEffect(e1)
	-- 对方把攻击力1500以上的怪兽反转召唤时才能发动。那些攻击力1500以上的怪兽破坏并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c29401950.target)
	e2:SetOperation(c29401950.activate)
	c:RegisterEffect(e2)
	-- 对方把攻击力1500以上的怪兽特殊召唤时才能发动。那些攻击力1500以上的怪兽破坏并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c29401950.target2)
	e3:SetOperation(c29401950.activate2)
	c:RegisterEffect(e3)
end
-- 筛选满足发动条件的怪兽：位于怪兽区、表侧表示、攻击力1500以上、由对方召唤·反转召唤·特殊召唤，且可以被除外。
function c29401950.filter(c,tp,ep)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetAttack()>=1500
		and ep~=tp and c:IsAbleToRemove()
end
-- 发动时的目标判定与信息设置：确认本次召唤的怪兽满足条件后，将召唤的怪兽组设为对象，并设置破坏与除外操作信息。
function c29401950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return c29401950.filter(tc,tp,ep) end
	-- 将当前即将处理的连锁对象设置为召唤成功的怪兽组（用于后续效果处理时确认关联性）。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次效果将要把对象怪兽破坏（破坏对象的数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置操作信息：本次效果将在破坏后把对象怪兽除外（除外对象的数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
-- 效果处理：取出召唤成功的怪兽，若其仍与效果关联且表侧表示、攻击力1500以上，则将其破坏并除外。
function c29401950.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>=1500 then
		-- 以效果破坏该怪兽，破坏后送去除外区（即破坏并除外）。
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
-- 特殊召唤专用筛选：怪兽位于怪兽区、表侧表示、攻击力1500以上、由对方玩家特殊召唤，且可以被除外。
function c29401950.filter2(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetAttack()>=1500 and c:IsSummonPlayer(1-tp)
		and c:IsAbleToRemove()
end
-- 特殊召唤时的目标判定与信息设置：确认特殊召唤的怪兽中存在符合条件的怪兽，将所有符合条件的怪兽设为对象，并设置破坏与除外操作信息。
function c29401950.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c29401950.filter2,1,nil,tp) end
	local g=eg:Filter(c29401950.filter2,nil,tp)
	-- 将当前连锁的对象设置为本次特殊召唤的全部怪兽组（使随后处理时能正确追踪相关卡片）。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次效果将破坏符合条件的全部特殊召唤怪兽（数量为g中卡数）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：本次效果将把上述怪兽全部除外（数量为g中卡数）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理时的再筛选：怪兽需表侧表示、攻击力1500以上、由对方特殊召唤、仍与效果关联且位于怪兽区。
function c29401950.filter3(c,e,tp)
	return c:IsFaceup() and c:GetAttack()>=1500 and c:IsSummonPlayer(1-tp)
		and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
end
-- 特殊召唤时的效果处理：筛选出所有满足条件的特殊召唤怪兽，若存在则将其全部破坏并除外。
function c29401950.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c29401950.filter3,nil,e,tp)
	if g:GetCount()>0 then
		-- 以效果破坏筛选出的所有怪兽，破坏后送去除外区（即破坏并除外）。
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
