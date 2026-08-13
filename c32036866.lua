--F.A.オーバー・ヒート
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只有对方场上才有怪兽存在的场合才能发动。从手卡把1只「方程式运动员」怪兽特殊召唤。这个效果特殊召唤的怪兽的等级直到回合结束时上升3星。
-- ②：自己的场地区域没有卡存在的场合，把墓地的这张卡除外才能发动。从自己的手卡·墓地选1张「方程式运动员」场地魔法卡发动。
function c32036866.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合才能发动。从手卡把1只「方程式运动员」怪兽特殊召唤。这个效果特殊召唤的怪兽的等级直到回合结束时上升3星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c32036866.condition)
	e1:SetTarget(c32036866.target)
	e1:SetOperation(c32036866.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的场地区域没有卡存在的场合，把墓地的这张卡除外才能发动。从自己的手卡·墓地选1张「方程式运动员」场地魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,32036866)
	e2:SetCondition(c32036866.condition2)
	-- 设置②效果的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32036866.target2)
	e2:SetOperation(c32036866.activate2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己场上没有怪兽，且对方场上有怪兽（即只有对方场上才有怪兽存在的场合）。
function c32036866.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上有怪兽存在。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 筛选手牌中属于『方程式运动员』字段且可被特殊召唤的怪兽。
function c32036866.filter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件检查：自己怪兽区有空位且手牌存在可特殊召唤的『方程式运动员』怪兽；满足后设定本次操作将进行1只怪兽的特殊召唤。
function c32036866.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌是否存在满足 filter 的『方程式运动员』怪兽。
		and Duel.IsExistingMatchingCard(c32036866.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本效果将把1只怪兽从手牌特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：从手牌选1只『方程式运动员』怪兽特殊召唤，并使其等级上升3星直到回合结束。
function c32036866.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认怪兽区有空位，若没有则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足条件的『方程式运动员』怪兽。
	local g=Duel.SelectMatchingCard(tp,c32036866.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的等级直到回合结束时上升3星。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(3)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：自己的场地区域没有卡存在。
function c32036866.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场地区域第0格没有卡，即场地区没有卡。
	return Duel.GetFieldCard(tp,LOCATION_FZONE,0)==nil
end
-- 筛选手牌·墓地中属于『方程式运动员』字段的场地魔法卡，且该场地魔法卡的效果可以发动。
function c32036866.filter2(c,tp)
	return c:IsSetCard(0x107) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- ②效果的发动条件检查：手牌或墓地存在可发动的『方程式运动员』场地魔法卡。
function c32036866.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查手牌·墓地是否存在满足 filter2 的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c32036866.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
end
-- ②效果处理：从手牌·墓地选1张『方程式运动员』场地魔法卡，若自己场地区已有卡则将其以规则送去墓地，然后将选中的卡放置到场地区并发动。
function c32036866.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手牌·墓地选择1张符合条件的『方程式运动员』场地魔法卡（从墓地选择时已过滤受王家长眠之谷影响的卡）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32036866.filter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域当前的卡（若有）。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将已有场地魔法卡以规则理由送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续的场地魔法卡发动成为一个独立事件，以保持正确时点。
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡表侧移动到自己场地区域，并使其效果立即适用（即发动该场地卡）。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发场地魔法卡发动成功的事件（EVENT_ACTIVATE），以便相关效果正确响应。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
