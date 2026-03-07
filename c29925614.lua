--混沌なる魅惑の女王
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只其他的光·暗属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。这张卡直到结束阶段当作和这个效果装备的怪兽同名卡使用。这个效果把光·暗属性的怪兽卡装备的场合，可以再从自己的卡组·墓地把1只暗属性「魅惑的女王」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建效果：①从手卡丢弃1只其他光·暗属性怪兽才能发动。这张卡从手卡特殊召唤。②以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。这张卡直到结束阶段当作和这个效果装备的怪兽同名卡使用。这个效果把光·暗属性的怪兽卡装备的场合，可以再从自己的卡组·墓地把1只暗属性「魅惑的女王」怪兽特殊召唤。
function s.initial_effect(c)
	-- ①：从手卡把1只其他的光·暗属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。这张卡直到结束阶段当作和这个效果装备的怪兽同名卡使用。这个效果把光·暗属性的怪兽卡装备的场合，可以再从自己的卡组·墓地把1只暗属性「魅惑的女王」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.eqcon1)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.eqcon2)
	c:RegisterEffect(e3)
end
-- 过滤函数：满足条件的卡必须是光属性或暗属性且可丢弃。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsDiscardable()
end
-- 效果处理：检查手牌是否存在满足条件的卡，若存在则提示选择并丢弃。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查手牌是否存在满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示信息：提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择卡片：从手牌中选择满足条件的1张卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 操作处理：将选中的卡送入墓地作为代价。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果处理：检查是否可以特殊召唤此卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查场上是否有空位可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：确定将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 操作处理：将此卡以正面表示特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 条件函数：判断是否满足②效果发动条件（非诱发即时效果）。
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前卡不在特定卡片影响范围内。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,95937545)
end
-- 条件函数：判断是否满足②效果发动条件（诱发即时效果）。
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前卡在特定卡片影响范围内。
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,95937545)
end
-- 过滤函数：满足条件的卡必须是怪兽且未被禁止、未在场上重复。
function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果处理：检查墓地是否存在满足条件的卡，若存在则提示选择。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,tp) end
	-- 条件判断：检查场上是否有空位可以装备。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 条件判断：检查墓地是否存在满足条件的卡。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 提示信息：提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择卡片：从墓地中选择满足条件的1张卡。
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置操作信息：确定将要装备的卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if bit.band(g:GetFirst():GetOriginalAttribute(),ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)~=0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(0)
	end
end
-- 过滤函数：满足条件的卡必须是魅惑的女王系列、暗属性且可特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：装备卡并设置效果，若装备的是光·暗属性怪兽则可再特殊召唤1只暗属性魅惑的女王怪兽。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标卡：获取当前连锁中选择的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 条件判断：检查装备卡是否有效且可装备。
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.Equip(tp,tc,c,false) then
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- 设置效果：装备卡不能被其他卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		-- 设置效果：此卡的卡号变为装备卡的卡号。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(tc:GetCode())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		if bit.band(tc:GetOriginalAttribute(),ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)~=0
			-- 条件判断：检查场上是否有空位可以特殊召唤。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 条件判断：检查卡组或墓地是否存在满足条件的卡。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
			-- 提示信息：询问玩家是否再特殊召唤1只怪兽。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把怪兽特殊召唤？"
			-- 中断效果：中断当前效果处理。
			Duel.BreakEffect()
			-- 提示信息：提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择卡片：从卡组或墓地中选择满足条件的1张卡。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 操作处理：将选中的卡特殊召唤到场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 限制函数：装备卡只能被自身装备。
function s.eqlimit(e,c)
	return c==e:GetOwner()
end
