--裁きの光
-- 效果：
-- ①：场上有「天空的圣域」存在的场合从手卡把1只光属性怪兽丢弃去墓地才能发动。从以下效果选1个适用。
-- ●把对方手卡确认，从那之中选1张卡送去墓地。
-- ●选对方场上1张卡送去墓地。
function c44595286.initial_effect(c)
	-- 将「天空的圣域」（卡号56433456）登记为此卡效果记载的关联卡名，用于效果文本提示及相关环境判定。
	aux.AddCodeList(c,56433456)
	-- ①：场上有「天空的圣域」存在的场合从手卡把1只光属性怪兽丢弃去墓地才能发动。从以下效果选1个适用。●把对方手卡确认，从那之中选1张卡送去墓地。●选对方场上1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_TOHAND+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44595286.condition)
	e1:SetCost(c44595286.cost)
	e1:SetTarget(c44595286.target)
	e1:SetOperation(c44595286.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件判定函数：仅当场上存在「天空的圣域」时，此卡才能发动。
function c44595286.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前生效的场地环境是否为「天空的圣域」（卡号56433456），若成立则满足发动条件。
	return Duel.IsEnvironment(56433456)
end
-- 定义丢弃手卡的筛选条件：该手卡为光属性怪兽，并且可以被丢弃且能作为代价送去墓地；用于筛选发动代价的候选卡。
function c44595286.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 定义代价支付函数：从手卡选择1只满足条件的光属性怪兽丢弃去墓地，作为发动此卡所需支付的代价。
function c44595286.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认手牌中存在至少1张光属性怪兽可满足丢弃代价，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44595286.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：玩家从手卡选择1只光属性怪兽以“代价+丢弃”的原因送去墓地。
	Duel.DiscardHand(tp,c44595286.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义发动时点合法目标检查函数：确保对方场上或手牌至少存在1张卡，使后续二选一效果至少有一种可以选择。
function c44595286.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段：统计对方场上与手牌的总卡数是否大于0，作为效果能否发动的条件。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
end
-- 定义效果处理函数：依据对方场上/手牌有卡的情况选择适用的效果；若选场上，则选对方场上1张卡送墓；若选手卡，则确认对方手卡后选1张送墓。
function c44595286.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部卡组成组g1，作为“选对方场上1张卡送去墓地”的候选范围。
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 获取对方手牌的全部卡组成组g2，作为“把对方手卡确认，从那之中选1张卡送去墓地”的候选范围。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local opt=0
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当对方场上和手牌都有卡时，弹出选项让玩家选择：选项0对应对方场上送墓，选项1对应对方手卡送墓；将选择结果+1存入opt以区分后续分支（1=场上，2=手卡）。
		opt=Duel.SelectOption(tp,aux.Stringid(44595286,0),aux.Stringid(44595286,1))+1  --"从对方场上选择1张卡送去墓地/从对方手卡选择1张卡送去墓地"
	elseif g1:GetCount()>0 then opt=1
	elseif g2:GetCount()>0 then opt=2
	end
	if opt==1 then
		-- 在“选对方场上1张卡送去墓地”分支中，向玩家展示“请选择要送去墓地的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选定的一张卡以“效果”原因送去墓地，实现“选对方场上1张卡送去墓地”。
		Duel.SendtoGrave(g,REASON_EFFECT)
	elseif opt==2 then
		-- 让对方玩家确认对方手牌中的所有卡，为下一步选择要送去墓地的手卡提供信息。
		Duel.ConfirmCards(tp,g2)
		-- 在“把对方手卡确认，从那之中选1张卡送去墓地”分支中，向玩家展示“请选择要送去墓地的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选定的手牌卡以“效果”原因送去墓地，实现“从那之中选1张卡送去墓地”。
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 效果处理完毕后，洗切对方手牌，以重置因被确认及取走卡片而改变的手牌顺序。
		Duel.ShuffleHand(1-tp)
	end
end
