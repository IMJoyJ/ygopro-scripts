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
	-- ●从自己的手卡·场上（表侧表示）把1只植物族怪兽送去墓地才能发动。自己回复500基本分。
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
	-- ●以自己墓地1只植物族怪兽为对象才能发动。那只怪兽回到卡组。那之后，自己回复500基本分。
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
	-- ●支付1000基本分才能发动。从自己墓地把1只「芳香」怪兽特殊召唤。
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
-- 作为代价的过滤条件：对象必须是植物族怪兽，且位于手牌或场上表侧表示，并且能够作为代价送去墓地。
function c15177750.costfilter(c)
	return c:IsRace(RACE_PLANT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从自己的手牌·场上表侧表示选择1只植物族怪兽送去墓地；先检查是否存在满足条件的卡，再选择并送去墓地。
function c15177750.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价满足检查：确认自己的手牌·场上表侧表示是否存在至少1只可作为代价送去墓地的植物族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15177750.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示本次发动的效果（显示本效果的描述文字），用于连锁确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示当前玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手牌·场上表侧表示选择1只满足条件的植物族怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c15177750.costfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选择的植物族怪兽作为代价（COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标处理：无取对象，设定回复对象为发动玩家、回复数值为500，并登记回复效果的操作信息。
function c15177750.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果回复的玩家设为发动玩家自身。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果回复的数值设定为500。
	Duel.SetTargetParam(500)
	-- 登记操作信息：发动玩家回复500基本分（CATEGORY_RECOVER）。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理：取得连锁中登记的回复玩家和数值，并实际执行基本分回复。
function c15177750.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家与回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，原因为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 该效果无实际代价，仅为发动时向对方提示效果选择。
function c15177750.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示本次发动的效果（显示本效果的描述文字），用于连锁确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 对象过滤条件：植物族怪兽且能够返回卡组。
function c15177750.tdfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToDeck()
end
-- 取对象效果：以自己墓地1只植物族怪兽为对象，设定回卡组和回复500基本分，并登记相关操作信息。
function c15177750.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15177750.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1只可作为对象且满足返回卡组条件的植物族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c15177750.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示当前玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只满足条件的植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c15177750.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：将对象怪兽返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记操作信息：发动玩家回复500基本分（CATEGORY_RECOVER）。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理：对象怪兽成功返回卡组后，中断处理并让发动玩家回复500基本分。
function c15177750.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象仍与效果关联，且已被效果成功送回卡组或额外卡组时，才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果处理，使后续的回复作为另一次处理进行（会错开时点）。
		Duel.BreakEffect()
		-- 让发动玩家回复500基本分。
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
-- 发动代价：支付1000基本分；先检查能否支付，再实际支付并提示对方。
function c15177750.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价满足检查：确认发动玩家是否能够支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 向对方玩家提示本次发动的效果（显示本效果的描述文字），用于连锁确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 让发动玩家支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 特殊召唤对象的过滤条件：持有「芳香」字段，且可以被特殊召唤。
function c15177750.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件检查：自己怪兽区域有空位，且墓地存在至少1只可特殊召唤的「芳香」怪兽；并登记特殊召唤的操作信息。
function c15177750.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足特殊召唤条件的「芳香」怪兽。
		and Duel.IsExistingMatchingCard(c15177750.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：从墓地特殊召唤1只「芳香」怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从自己墓地选择1只「芳香」怪兽特殊召唤；处理前确认效果仍关联且场上仍有空位。
function c15177750.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前确认：本卡效果仍然有效（与效果关联未被解除）且自己怪兽区域仍有空位，否则不处理。
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示当前玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只可特殊召唤且不受王家长眠之谷影响的「芳香」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15177750.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「芳香」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
