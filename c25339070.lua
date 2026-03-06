--堕天使マスティマ
-- 效果：
-- 自己对「堕天使 莫斯提马」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡丢弃2张其他的「堕天使」卡才能发动。这张卡特殊召唤。
-- ②：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
function c25339070.initial_effect(c)
	c:SetSPSummonOnce(25339070)
	-- ①：这张卡在手卡存在的场合，从手卡丢弃2张其他的「堕天使」卡才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25339070,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c25339070.spcost)
	e1:SetTarget(c25339070.sptg)
	e1:SetOperation(c25339070.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25339070,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,25339070)
	e2:SetCost(c25339070.cpcost)
	e2:SetTarget(c25339070.cptg)
	e2:SetOperation(c25339070.cpop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否包含至少2张可丢弃的「堕天使」卡
function c25339070.cfilter(c)
	return c:IsSetCard(0xef) and c:IsDiscardable()
end
-- 检查手卡中是否存在至少2张满足条件的「堕天使」卡，若存在则丢弃2张
function c25339070.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少2张满足条件的「堕天使」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25339070.cfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 从手卡丢弃2张满足条件的「堕天使」卡
	Duel.DiscardHand(tp,c25339070.cfilter,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 检查是否满足特殊召唤条件，包括场上是否有空位以及该卡是否可以被特殊召唤
function c25339070.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡正面表示特殊召唤到场上
function c25339070.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 检查玩家是否能支付1000基本分作为代价
function c25339070.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分作为代价
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，用于判断墓地中的「堕天使」魔法·陷阱卡是否可以被选为对象
function c25339070.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 设置效果目标，选择墓地中的「堕天使」魔法·陷阱卡作为对象，并准备处理其效果
function c25339070.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查墓地中是否存在至少1张满足条件的「堕天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c25339070.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地中的1张满足条件的「堕天使」魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c25339070.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁中的目标卡
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
	-- 设置将对象卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 执行效果复制并使用墓地卡的效果，之后将该卡送回卡组
function c25339070.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果，使后续效果处理视为不同时处理
	Duel.BreakEffect()
	-- 将对象卡送回卡组并洗牌
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
