--ライト・バニッシュ
-- 效果：
-- 把自己场上存在的1只名字带有「光道」的怪兽解放发动。怪兽的召唤·反转召唤·特殊召唤无效并破坏。
function c32233746.initial_effect(c)
	-- 把自己场上存在的1只名字带有「光道」的怪兽解放发动。怪兽的召唤·反转召唤·特殊召唤无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 判断当前是否存在尚未结算的连锁环节，确保效果可以在空闲时机发动。
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c32233746.cost)
	e1:SetTarget(c32233746.target)
	e1:SetOperation(c32233746.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 检查玩家场上是否存在至少1只名字带有「光道」的可解放怪兽，并选择其中1只进行解放。
function c32233746.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1只名字带有「光道」的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x38) end
	-- 从玩家场上选择1只名字带有「光道」的可解放怪兽。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x38)
	-- 以代價原因解放所选的怪兽。
	Duel.Release(g,REASON_COST)
end
-- 设置连锁操作信息，确定要无效召唤和破坏的目标怪兽。
function c32233746.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，确定要无效召唤的目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置连锁操作信息，确定要破坏的目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 使正在召唤·反转召唤·特殊召唤的怪兽召唤无效并破坏。
function c32233746.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤·反转召唤·特殊召唤的怪兽召唤无效。
	Duel.NegateSummon(eg)
	-- 以效果原因破坏目标怪兽。
	Duel.Destroy(eg,REASON_EFFECT)
end
