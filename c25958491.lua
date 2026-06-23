--エンシェント・ホーリー・ワイバーン
-- 效果：
-- 光属性调整＋调整以外的怪兽1只以上
-- 自己基本分比对方高的场合，这张卡的攻击力上升那个数值。自己基本分比对方低的场合，这张卡的攻击力下降那个数值。这张卡被战斗破坏送去墓地时，可以支付1000基本分把这张卡在自己场上特殊召唤。
function c25958491.initial_effect(c)
	-- 添加同调召唤手续，要求1只光属性调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 自己基本分比对方高的场合，这张卡的攻击力上升那个数值。自己基本分比对方低的场合，这张卡的攻击力下降那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c25958491.atkval)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地时，可以支付1000基本分把这张卡在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25958491,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c25958491.sumcon)
	e2:SetCost(c25958491.sumcost)
	e2:SetTarget(c25958491.sumtg)
	e2:SetOperation(c25958491.sumop)
	c:RegisterEffect(e2)
end
-- 计算攻击力变化值，返回自己LP减去对手LP的差值
function c25958491.atkval(e,c)
	local cont=c:GetControler()
	-- 返回自己LP减去对手LP的差值
	return Duel.GetLP(cont)-Duel.GetLP(1-cont)
end
-- 判断效果是否发动，确保卡片在墓地且因战斗破坏
function c25958491.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 支付1000基本分作为特殊召唤的费用
function c25958491.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 设置特殊召唤的处理目标，检查是否有足够的场地区域和卡片能否特殊召唤
function c25958491.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将卡片特殊召唤到场上
function c25958491.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否有足够的场地区域以及卡片是否与效果相关
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	-- 将卡片以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
