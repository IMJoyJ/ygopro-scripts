--ハイパーブレイズ
-- 效果：
-- ①：「神炎皇 乌利亚」用自身的方法特殊召唤的场合，也能把自己场上的里侧表示的陷阱卡送去墓地。
-- ②：自己的「神炎皇 乌利亚」进行战斗的攻击宣言时1次，从手卡·卡组把1张陷阱卡送去墓地才能发动。这个回合，那只怪兽的攻击力·守备力变成双方的场上·墓地的陷阱卡数量×1000。
-- ③：1回合1次，丢弃1张手卡才能发动。从自己墓地选「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只加入手卡或无视召唤条件特殊召唤。
function c16317140.initial_effect(c)
	-- 记录本卡效果中提到的三幻魔卡名（神炎皇乌利亚/降雷皇哈蒙/幻魔皇拉比艾尔），用于显示卡名关联信息。
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：「神炎皇 乌利亚」用自身的方法特殊召唤的场合，也能把自己场上的里侧表示的陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(16317140)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- ②：自己的「神炎皇 乌利亚」进行战斗的攻击宣言时1次，从手卡·卡组把1张陷阱卡送去墓地才能发动。这个回合，那只怪兽的攻击力·守备力变成双方的场上·墓地的陷阱卡数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16317140,0))  --"改变攻击力·守备力"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c16317140.atkcon)
	e3:SetCost(c16317140.atkcost)
	e3:SetOperation(c16317140.atkop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，丢弃1张手卡才能发动。从自己墓地选「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只加入手卡或无视召唤条件特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16317140,1))  --"加入手卡或特殊召唤"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c16317140.spcost)
	e4:SetTarget(c16317140.sptg)
	e4:SetOperation(c16317140.spop)
	c:RegisterEffect(e4)
end
-- 判定一张卡是否为可作为代价送去墓地的陷阱卡：必须是陷阱卡，且能被送去墓地作为代价。
function c16317140.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 筛选计入数量的陷阱卡：是陷阱卡，且为表侧表示存在于场上，或位于墓地。用于统计双方场上表侧陷阱卡和墓地陷阱卡的数量。
function c16317140.tpfilter(c)
	return c:IsType(TYPE_TRAP) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 攻击宣言时的发动条件：判定进行攻击宣言的怪兽是否为我方控制、表侧表示、卡名为「神炎皇 乌利亚」，若是则将其记录在效果Label中供后续处理使用。
function c16317140.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击宣言的怪兽卡。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽卡（若攻击对象为怪兽则为该卡，直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	if not a:IsControler(tp) then a,d=d,a end
	e:SetLabelObject(a)
	return a and a:IsCode(6007213) and a:IsFaceup() and a:IsControler(tp)
end
-- ②的发动代价：从手卡或卡组选择1张陷阱卡送去墓地。
function c16317140.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认玩家手卡或卡组中是否存在至少1张可作为代价送去墓地的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16317140.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 发送选择提示消息，提示玩家选择要送去墓地的卡（HINTMSG_TOGRAVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家从手卡或卡组选择1张满足条件的陷阱卡（既不除外也不受其他限制）作为代价。
	local g=Duel.SelectMatchingCard(tp,c16317140.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选择的陷阱卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g:GetFirst(),REASON_COST)
end
-- ②效果处理：若攻击怪兽仍表侧且参与战斗，则计算场上·墓地陷阱卡数量×1000，并使其攻击力·守备力直到回合结束时变成该数值。
function c16317140.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 统计双方场上表侧表示及墓地的陷阱卡总数，并乘以1000作为新的攻击力/守备力数值。
		local val=Duel.GetMatchingGroupCount(c16317140.tpfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)*1000
		if val==0 then return end
		-- 这个回合，那只怪兽的攻击力变成双方的场上·墓地的陷阱卡数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(val)
		tc:RegisterEffect(e1)
		-- 这个回合，那只怪兽的守备力变成双方的场上·墓地的陷阱卡数量×1000。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(val)
		tc:RegisterEffect(e2)
	end
end
-- ③的检索/选择筛选：目标必须是「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」之一，并且能够加入手卡或能够被无视召唤条件特殊召唤。
function c16317140.spfilter(c,e,tp)
	return c:IsCode(32491822,6007213,69890967)
		-- 进一步判断：该怪兽可以加入手卡，或者（自己怪兽区域有空位且可以无视召唤条件特殊召唤）满足其中之一即可作为可选目标。
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
-- ③的发动代价：丢弃1张手卡。
function c16317140.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中是否存在至少1张可丢弃的卡（Card.IsDiscardable）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家从手卡选择1张卡并丢弃，作为③发动的代价（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ③的发动目标阶段：检查墓地是否存在符合条件的怪兽，并设置操作信息为可能回手牌或可能特殊召唤，各1张，来源为墓地。
function c16317140.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：确认墓地存在至少1只满足spfilter条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c16317140.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：可能将1张墓地卡加入手卡。用于检测回手牌效果的相关互动。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：可能将1张墓地卡特殊召唤。用于检测特召效果的相关互动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：玩家从墓地选择1只符合条件的怪兽（经过王家长眠之谷过滤），然后选择加入手卡或特殊召唤，执行对应操作。
function c16317140.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示消息，提示玩家选择要操作的卡（HINTMSG_OPERATECARD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从墓地选择1只满足spfilter条件且不受王家长眠之谷影响的怪兽。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16317140.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	if sc then
		-- 判断是否满足特殊召唤条件：自己怪兽区域有空位，且该怪兽可以无视召唤条件特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,true,false)
			-- 如果该怪兽不能加入手卡，或玩家在“加入手卡/特殊召唤”选项中选择了特殊召唤（选项值==1），则进入特殊召唤分支。
			and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上，无视召唤条件、不解除苏生限制（nocheck=true, nolimit=false）。
			Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
		else
			-- 否则将选择的怪兽加入其持有者的手卡（REASON_EFFECT）。
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
		end
	end
end
