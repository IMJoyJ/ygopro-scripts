--古代の機械司令
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·场上（表侧表示）把1只「古代的机械巨人」送去墓地才能发动。进行1只「古代的机械」怪兽的召唤。
-- ②：自己把「古代的机械巨人」召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只「古代的机械巨人」无视召唤条件特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从手卡把1张「古代的机械」永续陷阱卡在自己场上表侧表示放置。
function c27483935.initial_effect(c)
	-- 记录这张卡上记载着「古代的机械巨人」（83104731）的卡名，用于相关卡名判定。
	aux.AddCodeList(c,83104731)
	-- 效果①：从自己的手卡·卡组·场上（表侧表示）把1只「古代的机械巨人」送去墓地才能发动。进行1只「古代的机械」怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27483935,0))  --"进行召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27483935)
	e1:SetCost(c27483935.scost)
	e1:SetTarget(c27483935.stg)
	e1:SetOperation(c27483935.sop)
	c:RegisterEffect(e1)
	-- 效果②：自己把「古代的机械巨人」召唤·特殊召唤的场合才能发动。从自己的手卡·墓地把1只「古代的机械巨人」无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27483935,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27483936)
	e2:SetCondition(c27483935.spcon)
	e2:SetTarget(c27483935.sptg)
	e2:SetOperation(c27483935.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 效果③：把墓地的这张卡除外才能发动。从手卡把1张「古代的机械」永续陷阱卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27483935,2))  --"放置永续陷阱"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,27483937)
	-- 为③效果设置发动代价：把墓地的这张卡除外（使用辅助函数aux.bfgcost作为标准除外代价）。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c27483935.tftg)
	e4:SetOperation(c27483935.tfop)
	c:RegisterEffect(e4)
end
-- 代价过滤器：选择1张「古代的机械巨人」作为代价送去墓地，同时确认手牌或自己场上存在1只可以通常召唤的「古代的机械」怪兽（排除将要作为代价的这张卡）。
function c27483935.costfilter(c,tp)
	return c:IsCode(83104731) and c:IsAbleToGraveAsCost()
		-- 追加条件：手牌或自己场上必须存在满足sumfilter的「古代的机械」怪兽，且不能是当前候选作为代价的那张卡。
		and Duel.IsExistingMatchingCard(c27483935.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c)
end
-- ①效果的代价处理：检查手卡·卡组·场上是否存在可送的「古代的机械巨人」；若存在则提示选卡、选择1张送去墓地，完成发动代价。
function c27483935.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价发动检查（chk==0）：确认手卡·卡组·场上存在至少1张满足costfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c27483935.costfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡·卡组·场上选择1张满足costfilter的「古代的机械巨人」作为代价。
	local g=Duel.SelectMatchingCard(tp,c27483935.costfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的「古代的机械巨人」送去墓地，并标记为发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的目标定义：确认存在可以通常召唤的「古代的机械」怪兽，并设置操作信息为召唤。
function c27483935.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查（chk==0）：手牌或自己场上存在满足sumfilter的「古代的机械」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c27483935.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理信息：本效果属于召唤效果（CATEGORY_SUMMON），处理时预计进行1只怪兽的召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 召唤过滤器：筛选出卡名包含「古代的机械」字段（0x7）且可以无视通常召唤次数限制进行召唤的怪兽。
function c27483935.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsSetCard(0x7)
end
-- ①效果处理：玩家选择1只满足条件的「古代的机械」怪兽，执行通常召唤（忽略本回合通召次数限制）。
function c27483935.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌或自己场上选择1只满足sumfilter的「古代的机械」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27483935.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行通常召唤：调用Duel.Summon，ignore_count=true表示不占用通常召唤次数，以效果处理方式召唤该怪兽。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 事件过滤器：判断事件涉及的怪兽是否为表侧表示的「古代的机械巨人」（83104731）。
function c27483935.cfilter(c)
	return c:IsFaceup() and c:IsCode(83104731)
end
-- ②效果的触发条件：本次召唤·特殊召唤成功的怪兽中存在表侧表示的「古代的机械巨人」。
function c27483935.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27483935.cfilter,1,nil)
end
-- 特殊召唤对象过滤器：选择「古代的机械巨人」，且允许无视召唤条件（nocheck=true）进行特殊召唤。
function c27483935.filter1(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的目标定义：自己主要怪兽区有空位，且手卡或墓地存在可特殊召唤的「古代的机械巨人」。
function c27483935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查之一：自己场上主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 目标检查之二：手卡或墓地中存在满足filter1的「古代的机械巨人」。
		and Duel.IsExistingMatchingCard(c27483935.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理信息：本效果为特殊召唤效果，从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：选择手卡或墓地的「古代的机械巨人」（排除受王家长眠之谷影响的卡），无视召唤条件以表侧表示特殊召唤。
function c27483935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认主要怪兽区仍有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足filter1且不受王家长眠之谷影响的「古代的机械巨人」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27483935.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「古代的机械巨人」以表侧表示特殊召唤到自己场上，无视召唤条件（nocheck=true）。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 永续陷阱过滤器：筛选手牌中字段为「古代的机械」的永续陷阱卡，且该卡不被禁止、能在自己场上表侧表示放置（不违反卡名唯一规则）。
function c27483935.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsSetCard(0x7)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ③效果的目标定义：自己魔陷区有空位，且手牌存在可放置的「古代的机械」永续陷阱卡。
function c27483935.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查之一：自己魔陷区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 目标检查之二：手牌中存在满足pfilter的「古代的机械」永续陷阱卡。
		and Duel.IsExistingMatchingCard(c27483935.pfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
-- ③效果处理：从手牌选择1张「古代的机械」永续陷阱卡，表侧表示放置到自己魔陷区并立即适用效果。
function c27483935.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认魔陷区仍有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 显示选择提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手牌选择1张满足pfilter的「古代的机械」永续陷阱卡。
	local tc=Duel.SelectMatchingCard(tp,c27483935.pfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	-- 将选中的永续陷阱卡移动到自己的魔陷区，表侧表示放置，并立刻使其效果适用。
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
