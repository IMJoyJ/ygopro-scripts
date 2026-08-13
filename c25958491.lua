--エンシェント・ホーリー・ワイバーン
-- 效果：
-- 光属性调整＋调整以外的怪兽1只以上
-- 自己基本分比对方高的场合，这张卡的攻击力上升那个数值。自己基本分比对方低的场合，这张卡的攻击力下降那个数值。这张卡被战斗破坏送去墓地时，可以支付1000基本分把这张卡在自己场上特殊召唤。
function c25958491.initial_effect(c)
	-- 为「古代圣翼龙」添加同调召唤手续：调整怪兽必须为光属性，调整以外的怪兽至少1只（无其他限制）。
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
-- 定义攻击力增减值的计算函数：以这张卡的控制者当前LP减去对方当前LP的差值作为攻击力变化量。
function c25958491.atkval(e,c)
	local cont=c:GetControler()
	-- 返回控制者当前LP与对方当前LP的差值，正数表示攻击力上升，负数表示攻击力下降。
	return Duel.GetLP(cont)-Duel.GetLP(1-cont)
end
-- 特殊召唤效果的发动条件：这张卡被战斗破坏后送入墓地，且当前确实位于墓地、破坏原因属于战斗。
function c25958491.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 特殊召唤效果的发动代价：需要支付1000基本分，先检查是否足够，再实际支付。
function c25958491.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段，确认该玩家能否支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动效果的费用。
	Duel.PayLPCost(tp,1000)
end
-- 特殊召唤效果的目标判定：需要自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c25958491.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区是否存在可用空格（至少1个）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次效果处理中包含特殊召唤的操作信息登记到连锁中，供相关卡片进行时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若仍有空位且这张卡仍与效果关联，则将其表侧攻击表示特殊召唤到自己场上。
function c25958491.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时若自己主要怪兽区没有空位或这张卡已不关联本次效果，则特殊召唤失败并结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上，不进行召唤条件/苏生限制的额外检查。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
