--恵みの風
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的手卡·场上（表侧表示）把1只植物族怪兽送去墓地才能发动。自己回复500基本分。
-- ●以自己墓地1只植物族怪兽为对象才能发动。那只怪兽回到卡组。那之后，自己回复500基本分。
-- ●支付1000基本分才能发动。从自己墓地把1只「芳香」怪兽特殊召唤。
function c15177750.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 效果原文：从自己的手卡·场上（表侧表示）把1只植物族怪兽送去墓地才能发动。自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15177750,0))  --"送去墓地回复基本分"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,15177750)
	e2:SetCost(c15177750.reccost)
	e2:SetTarget(c15177750.rectg)
	e2:SetOperation(c15177750.recop)
	c:RegisterEffect(e2)
	-- 效果原文：以自己墓地1只植物族怪兽为对象才能发动。那只怪兽回到卡组。那之后，自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15177750,1))  --"回到卡组回复基本分"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,15177750)
	e3:SetCost(c15177750.tdcost)
	e3:SetTarget(c15177750.tdtg)
	e3:SetOperation(c15177750.tdop)
	c:RegisterEffect(e3)
	-- 效果原文：支付1000基本分才能发动。从自己墓地把1只「芳香」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15177750,2))  --"支付基本分特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,15177750)
	e4:SetCost(c15177750.spcost)
	e4:SetTarget(c15177750.sptg)
	e4:SetOperation(c15177750.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为可作为代价的植物族怪兽（手牌或场上表侧表示）
function c15177750.costfilter(c)
	return c:IsRace(RACE_PLANT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 效果处理：检查是否有满足条件的植物族怪兽可作为代价并选择送去墓地
function c15177750.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上或手牌是否存在满足条件的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c15177750.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 提示信息：向对方玩家提示发动了“送去墓地回复基本分”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示信息：提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的植物族怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c15177750.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果目标：回复500基本分
function c15177750.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为500
	Duel.SetTargetParam(500)
	-- 设置操作信息：回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理：执行回复基本分操作
function c15177750.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分操作
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 效果处理：支付基本分后发动效果
function c15177750.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示信息：向对方玩家提示发动了“支付基本分特殊召唤”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤函数，用于判断是否为可送回卡组的植物族怪兽
function c15177750.tdfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToDeck()
end
-- 设置效果目标：选择墓地中的植物族怪兽作为对象
function c15177750.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15177750.tdfilter(chkc) end
	-- 条件判断：检查墓地是否存在满足条件的植物族怪兽
	if chk==0 then return Duel.IsExistingTarget(c15177750.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示信息：提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择满足条件的植物族怪兽作为对象
	local g=Duel.SelectTarget(tp,c15177750.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将对象怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理：执行将怪兽送回卡组并回复基本分
function c15177750.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 条件判断：目标怪兽存在且已送回卡组且在卡组或额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 执行回复基本分操作
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
-- 效果处理：支付1000基本分后发动效果
function c15177750.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查当前玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 提示信息：向对方玩家提示发动了“支付基本分特殊召唤”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 扣除当前玩家1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，用于判断是否为可特殊召唤的芳香怪兽
function c15177750.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：检查是否有可特殊召唤的芳香怪兽
function c15177750.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查当前玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件判断：检查墓地是否存在满足条件的芳香怪兽
		and Duel.IsExistingMatchingCard(c15177750.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只芳香怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：执行特殊召唤操作
function c15177750.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：检查当前卡片是否仍在场上且场上是否有空位
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示信息：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的芳香怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15177750.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
