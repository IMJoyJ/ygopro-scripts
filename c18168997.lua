--堕天使ネルガル
-- 效果：
-- 自己对「堕天使 内尔伽勒」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：自己的天使族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
function c18168997.initial_effect(c)
	c:SetSPSummonOnce(18168997)
	-- ①：自己的天使族怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯穿伤害效果仅适用于我方场上的天使族怪兽（即给这些怪兽附加贯穿伤害能力）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	c:RegisterEffect(e1)
	-- 那个②的效果1回合只能使用1次。②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18168997,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,18168997)
	e2:SetCost(c18168997.cpcost)
	e2:SetTarget(c18168997.cptg)
	e2:SetOperation(c18168997.cpop)
	c:RegisterEffect(e2)
end
-- ②效果的发动代价函数：检查并支付1000基本分作为发动COST，无法支付则不能发动。
function c18168997.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认玩家能否支付1000基本分，不能则发动不合法。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 墓地检索过滤条件：选择卡名含「堕天使」的魔法·陷阱卡，且可以返回卡组并拥有可发动的效果。
function c18168997.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- ②效果的取对象处理：选择自己墓地1张符合条件的「堕天使」魔法·陷阱卡作为对象，读取其可发动的效果并临时建立关联，同时验证该效果的对象要求；最后设置回卡组的操作信息。
function c18168997.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 发动时确认自己墓地是否存在至少1张符合条件的「堕天使」魔法·陷阱卡可以选择。
	if chk==0 then return Duel.IsExistingTarget(c18168997.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择对象的提示信息，要求玩家选择1张墓地「堕天使」魔陷卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从自己墓地选择1张符合条件的「堕天使」魔法·陷阱卡作为本效果的取对象目标。
	local g=Duel.SelectTarget(tp,c18168997.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除系统自动记录的目标对象，因为后续需要手动建立与复制效果的关联。
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止复制使用的效果被视为原始效果而被错误响应。
	Duel.ClearOperationInfo(0)
	-- 设置本次连锁的操作信息：效果处理后对象卡将返回卡组（回卡组类别），数量为1，目标为所选卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取出预存的目标卡效果；若目标卡仍与效果关联，则执行该效果的处理；之后中断连锁，将目标卡返回卡组并洗牌。
function c18168997.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果链，使后续回卡组处理与已适用的效果处理分开，避免错误时机判定。
	Duel.BreakEffect()
	-- 将被复制效果的墓地「堕天使」魔陷卡返回持有者卡组并洗牌，返回原因为效果。
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
