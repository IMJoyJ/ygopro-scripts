--堕天使マスティマ
-- 效果：
-- 自己对「堕天使 莫斯提马」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡丢弃2张其他的「堕天使」卡才能发动。这张卡特殊召唤。
-- ②：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
function c25339070.initial_effect(c)
	c:SetSPSummonOnce(25339070)
	-- 自己对「堕天使 莫斯提马」1回合只能有1次特殊召唤。①：这张卡在手卡存在的场合，从手卡丢弃2张其他的「堕天使」卡才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25339070,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c25339070.spcost)
	e1:SetTarget(c25339070.sptg)
	e1:SetOperation(c25339070.spop)
	c:RegisterEffect(e1)
	-- 那个②的效果1回合只能使用1次。②：自己·对方回合，支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡发动时的效果适用。那之后，那张卡回到卡组。
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
-- 过滤函数：检查卡片是否满足条件——卡名属于「堕天使」字段且可以作为代价丢弃。
function c25339070.cfilter(c)
	return c:IsSetCard(0xef) and c:IsDiscardable()
end
-- ①效果的发动代价：检查手牌中是否存在至少2张其他「堕天使」卡可丢弃；若存在，则丢弃2张其他「堕天使」卡作为代价。
function c25339070.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手牌中至少有2张其他满足条件的「堕天使」卡可以作为丢弃代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c25339070.cfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 支付代价：从手牌丢弃2张其他「堕天使」卡，丢弃原因为代价并作为效果发动COST。
	Duel.DiscardHand(tp,c25339070.cfilter,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果发动条件：确认自己场上有空闲怪兽区，且这张卡能够被特殊召唤。
function c25339070.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将这次效果处理登记为特殊召唤这张卡（数量1），供相关卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c25339070.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（不使用特殊召唤方式限制，不无视召唤条件/苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果发动代价：确认可以支付1000基本分，然后支付1000基本分。
function c25339070.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己基本分是否足够支付1000。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 筛选函数：选择墓地里满足「堕天使」字段、是魔法·陷阱卡、可以回到卡组，并且拥有可发动效果的卡（用于复制其效果）。
function c25339070.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- ②效果的取对象/准备：若是连锁中的对象合法性确认，则用保存的原效果目标函数进行校验；否则选择墓地1张符合条件的「堕天使」魔法·陷阱卡，获取其可发动的效果，将该效果保存为本效果的Label，并在发动时调用其目标函数；同时清除原有操作信息，登记最终回卡组的操作信息。
function c25339070.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 确认墓地存在至少1张满足条件的「堕天使」魔法·陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c25339070.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择对象的提示（请选择效果的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己墓地选择1张符合筛选条件的「堕天使」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c25339070.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除自动设置的对象，以便手动建立复制效果所需的对象关系。
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，避免复制效果的分类信息残留造成干扰。
	Duel.ClearOperationInfo(0)
	-- 重新登记操作信息：标记最终将被复制的魔陷送回卡组（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：取出保存的「堕天使」魔陷效果；若该卡仍与效果关联，则继承其内部Label并执行该魔陷的发动效果；随后中断连锁，再将该魔陷返回卡组。
function c25339070.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果处理，使复制效果与回卡组处理分开时点，避免同时处理导致时点错误。
	Duel.BreakEffect()
	-- 将被复制的「堕天使」魔法·陷阱卡送回持有者卡组并洗牌（原因：效果）。
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
