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
	-- ②：自己的场地区域没有卡存在的场合，把墓地的这张卡除外才能发动。从自己的手卡·墓地选1张「方程式运动员」场地魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,32036866)
	e2:SetCondition(c32036866.condition2)
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32036866.target2)
	e2:SetOperation(c32036866.activate2)
	c:RegisterEffect(e2)
end
-- 判断对方场上存在怪兽，己方场上不存在怪兽
function c32036866.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 己方场上不存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 对方场上存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤手卡中可以特殊召唤的「方程式运动员」怪兽
function c32036866.filter(c,e,tp)
	return c:IsSetCard(0x107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要特殊召唤的怪兽
function c32036866.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c32036866.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果
function c32036866.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断己方场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c32036866.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的怪兽等级上升3星
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(3)
		tc:RegisterEffect(e1)
	end
end
-- 判断己方场上没有场地魔法卡
function c32036866.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 己方场上没有场地魔法卡
	return Duel.GetFieldCard(tp,LOCATION_FZONE,0)==nil
end
-- 过滤手卡或墓地中的「方程式运动员」场地魔法卡
function c32036866.filter2(c,tp)
	return c:IsSetCard(0x107) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 设置效果处理时要发动的场地魔法卡
function c32036866.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡或墓地中存在满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32036866.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 处理发动场地魔法卡效果
function c32036866.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32036866.filter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取己方场上已存在的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将己方场上已存在的场地魔法卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡放置到己方场上
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发场地魔法卡的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
