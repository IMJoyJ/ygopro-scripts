--ライト・バニッシュ
-- 效果：
-- 把自己场上存在的1只名字带有「光道」的怪兽解放发动。怪兽的召唤·反转召唤·特殊召唤无效并破坏。
function c32233746.initial_effect(c)
	-- 把自己场上存在的1只名字带有「光道」的怪兽解放发动。怪兽的召唤·反转召唤·特殊召唤无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	-- 设置效果的发动条件为没有正在处理的连锁（即仅在召唤、反转召唤、特殊召唤之际不入连锁地发动）。
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
-- 定义代价函数：玩家需要解放自己场上1只名字带有「光道」的怪兽作为发动代价。
function c32233746.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动前检查（chk==0），则确认自己场上是否存在至少1只可解放的、卡名含有「光道」的怪兽；若存在才能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x38) end
	-- 选择自己场上1只名字带有「光道」的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x38)
	-- 将选择的怪兽解放，作为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义效果发动时的目标处理函数：效果发动必定成功，无需指定对象；把当前被无效召唤的怪兽组记录到操作信息中，用于后续处理。
function c32233746.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向连锁处理登记本次操作包含“无效召唤”分类，对象为当前召唤的怪兽组，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 向连锁处理登记本次操作包含“破坏”分类，对象同样为当前召唤的怪兽组，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 定义效果处理函数：对当前正在召唤·反转召唤·特殊召唤的怪兽群执行召唤无效，并将其破坏。
function c32233746.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在召唤/反转召唤/特殊召唤的怪兽（eg）的召唤无效化。
	Duel.NegateSummon(eg)
	-- 以效果原因破坏那些已被无效召唤的怪兽。
	Duel.Destroy(eg,REASON_EFFECT)
end
