--ヴァンパイア・シフト
-- 效果：
-- 自己的场地卡区域没有卡存在，自己场上表侧表示存在的怪兽只有不死族怪兽的场合才能发动。从卡组选1张「吸血鬼帝国」发动。那之后，可以从自己墓地选1只名字带有「吸血鬼」的暗属性怪兽表侧守备表示特殊召唤。「吸血鬼移地」在1回合只能发动1张。
function c22900598.initial_effect(c)
	-- 将卡号62188962（吸血鬼帝国）记录到本卡的代码列表中，用于标记本卡效果涉及该卡名。
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
-- 发动条件判定：己方场地区没有卡，且己方场上表侧表示怪兽存在且全部为不死族怪兽。
function c22900598.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场地区域是否没有卡；若存在卡则不满足发动条件。
	if Duel.GetFieldCard(tp,LOCATION_FZONE,0)~=nil then return false end
	-- 获取己方场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()>0 and g:FilterCount(Card.IsRace,nil,RACE_ZOMBIE)==g:GetCount()
end
-- 定义过滤器：卡名为「吸血鬼帝国」且其发动效果当前可由tp发动（忽略发动位置和对象要求）。
function c22900598.filter(c,tp)
	return c:IsCode(62188962) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 发动时点处理：确认卡组中存在满足条件的「吸血鬼帝国」才能发动本卡。
function c22900598.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法发动检查时，判断卡组中是否存在至少1张满足过滤条件的「吸血鬼帝国」。
	if chk==0 then return Duel.IsExistingMatchingCard(c22900598.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 特殊召唤过滤器：墓地中名字带有「吸血鬼」、暗属性、且可以以表侧守备表示特殊召唤的怪兽。
function c22900598.spfilter(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理：从卡组选取「吸血鬼帝国」发动，然后询问是否从墓地特殊召唤符合条件的吸血鬼暗属性怪兽。
function c22900598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组取得第一张满足条件的「吸血鬼帝国」。
	local tc=Duel.GetFirstMatchingCard(c22900598.filter,tp,LOCATION_DECK,0,nil,tp)
	if tc then
		-- 将「吸血鬼帝国」移动到己方场地区域，表侧表示放置，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发该场地魔法卡的发动时点事件，使其发动被系统记录并进入连锁，以便其他卡响应。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		-- 检查己方主要怪兽区域是否有空位；若无空位则无法进行后续特殊召唤，终止处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 取得墓地中满足特殊召唤条件且不因王家长眠之谷等效果而无法特殊召唤的怪兽集合。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c22900598.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 若存在可特殊召唤的怪兽且玩家确认选择“是”，则进行后续特殊召唤处理。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22900598,0)) then  --"是否要从墓地选1只名字带有「吸血鬼」的暗属性怪兽表侧守备表示特殊召唤？"
			-- 中断当前效果链，使后续特殊召唤处理作为独立处理，避免错失时点。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的提示消息，要求玩家选择卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g=sg:Select(tp,1,1,nil)
			-- 将选择的怪兽以表侧守备表示特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
