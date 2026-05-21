--昇天の角笛
-- 效果：
-- 自己场上的1只怪兽作为祭品。怪兽的召唤·反转召唤·特殊召唤无效并破坏。
function c98069388.initial_effect(c)
	-- 自己场上的1只怪兽作为祭品。怪兽的召唤·反转召唤·特殊召唤无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设置发动条件：只能在非连锁状态下的召唤之际发动
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c98069388.cost)
	e1:SetTarget(c98069388.target)
	e1:SetOperation(c98069388.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 代价处理：解放自己场上的1只怪兽
function c98069388.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
	-- 让玩家选择自己场上的1只怪兽
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 目标判定：设置无效召唤和破坏的操作信息
function c98069388.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效召唤正在召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：破坏正在召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理：使召唤无效并破坏
function c98069388.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的召唤、反转召唤或特殊召唤无效
	Duel.NegateSummon(eg)
	-- 将该召唤被无效的怪兽破坏
	Duel.Destroy(eg,REASON_EFFECT)
end
