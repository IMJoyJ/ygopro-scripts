--ヴァンパイア・シフト
-- 效果：
-- 自己的场地卡区域没有卡存在，自己场上表侧表示存在的怪兽只有不死族怪兽的场合才能发动。从卡组选1张「吸血鬼帝国」发动。那之后，可以从自己墓地选1只名字带有「吸血鬼」的暗属性怪兽表侧守备表示特殊召唤。「吸血鬼移地」在1回合只能发动1张。
function c22900598.initial_effect(c)
	-- 记录此卡与「吸血鬼帝国」的关联
	aux.AddCodeList(c,62188962)
	-- 自己的场地卡区域没有卡存在，自己场上表侧表示存在的怪兽只有不死族怪兽的场合才能发动。从卡组选1张「吸血鬼帝国」发动。那之后，可以从自己墓地选1只名字带有「吸血鬼」的暗属性怪兽表侧守备表示特殊召唤。「吸血鬼移地」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22900598+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c22900598.condition)
	e1:SetTarget(c22900598.target)
	e1:SetOperation(c22900598.activate)
	c:RegisterEffect(e1)
end
-- 检查场地是否为空且己方场上表侧表示怪兽均为不死族
function c22900598.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方场地卡区域有卡则不能发动
	if Duel.GetFieldCard(tp,LOCATION_FZONE,0)~=nil then return false end
	-- 获取己方场上表侧表示怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()>0 and g:FilterCount(Card.IsRace,nil,RACE_ZOMBIE)==g:GetCount()
end
-- 过滤出卡号为「吸血鬼帝国」且可发动的卡
function c22900598.filter(c,tp)
	return c:IsCode(62188962) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 判断卡组是否存在可发动的「吸血鬼帝国」
function c22900598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「吸血鬼帝国」
	if chk==0 then return Duel.IsExistingMatchingCard(c22900598.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 过滤出名字带有「吸血鬼」且属性为暗的怪兽
function c22900598.spfilter(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理效果发动流程：将「吸血鬼帝国」移至场地区域并发动其效果，随后判断是否能从墓地特殊召唤怪兽
function c22900598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组检索满足条件的「吸血鬼帝国」
	local tc=Duel.GetFirstMatchingCard(c22900598.filter,tp,LOCATION_DECK,0,nil,tp)
	if tc then
		-- 将「吸血鬼帝国」移至己方场地
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发「吸血鬼帝国」的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		-- 若己方怪兽区域无空位则不继续处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取己方墓地中满足条件的怪兽集合
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c22900598.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否有满足条件的怪兽且己方选择发动特殊召唤
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22900598,0)) then  --"是否要从墓地选1只名字带有「吸血鬼」的暗属性怪兽表侧守备表示特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示己方选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g=sg:Select(tp,1,1,nil)
			-- 将选中的怪兽以守备表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
