--混沌なる魅惑の女王
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只其他的光·暗属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。这张卡直到结束阶段当作和这个效果装备的怪兽同名卡使用。这个效果把光·暗属性的怪兽卡装备的场合，可以再从自己的卡组·墓地把1只暗属性「魅惑的女王」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：为「混沌魅惑的女王」注册三个效果——①从手卡丢弃光/暗怪兽特殊召唤自身的起动效果；②取墓地怪兽装备的起动效果；③同一装备效果在满足条件下可作为二速效果发动。
function s.initial_effect(c)
	-- ①：从手卡丢弃1只其他的光·暗属性怪兽才能发动。这张卡从手卡特殊召唤。
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
-- 定义①代价的过滤函数：选择手牌中光属性或暗属性、且可以丢弃的怪兽作为代价（自身在调用处已排除）。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsDiscardable()
end
-- ①代价处理：先检查是否存在可丢弃的光/暗怪兽，若存在则提示玩家选择1张并丢弃到墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认手牌中除自身外存在至少1张光/暗属性且可丢弃的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家显示“请选择要丢弃的手牌”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手牌选择1张满足条件且非自身的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的代价怪兽丢弃到墓地（计入代价与丢弃原因）。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- ①的发动目标/条件检查：场上存在可用主要怪兽区，且这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将对这张卡进行特殊召唤，便于后续卡处理时点判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者（发动者）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- e2（一速装备效果）的发动条件：当此卡未被赋予二速发动能力时，可作为起动效果发动。
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前不满足二速化条件，即按通常起动效果处理。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,95937545)
end
-- e3（二速装备效果）的发动条件：当此卡被特定效果赋予二速发动能力时，可作为诱发即时效果发动。
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前满足二速化条件，允许在对方回合自由时点发动。
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,95937545)
end
-- 装备对象过滤函数：选择墓地中的怪兽卡，且该卡不被禁止作装备卡，并满足场上同名卡唯一限制。
function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ②的取对象处理：验证对象合法性与装备区空位，选择1只墓地怪兽作为对象并设置相关操作信息。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,tp) end
	-- 检查自己魔陷区是否有空位以放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地中是否存在至少1只可作为装备对象的怪兽。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 向玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只墓地怪兽作为本效果的装备对象。
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置操作信息：该效果会使对象怪兽离开墓地（被装备）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if bit.band(g:GetFirst():GetOriginalAttribute(),ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)~=0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(0)
	end
end
-- 定义可被追加特殊召唤的怪兽过滤条件：暗属性、属于「魅惑的女王」系列（0x3）、且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的效果处理：将对象怪兽装备给此卡；若装备的是光/暗属性怪兽且满足条件，则询问玩家是否从卡组·墓地追加特殊召唤1只暗属性「魅惑的女王」怪兽。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认此卡与对象怪兽仍与效果关联、此卡表侧表示、对象不受王家长眠之谷影响，然后将其作为装备卡装备给此卡。
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.Equip(tp,tc,c,false) then
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- 那只怪兽当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		-- 这张卡直到结束阶段当作和这个效果装备的怪兽同名卡使用。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(tc:GetCode())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
		if bit.band(tc:GetOriginalAttribute(),ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)~=0
			-- 检查自己场上是否有空余的主要怪兽区用于追加特殊召唤。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组·墓地中是否存在1只不受王家长眠之谷影响的暗属性「魅惑的女王」怪兽可特殊召唤。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
			-- 询问玩家是否选择追加特殊召唤（是/否）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把怪兽特殊召唤？"
			-- 中断当前效果处理，使追加的特殊召唤作为单独处理，避免错过时点。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组·墓地选择1只满足条件的暗属性「魅惑的女王」怪兽。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽表侧表示特殊召唤到自己的场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 装备限制函数：该装备卡只能装备给原效果持有者（即「混沌魅惑的女王」自身）。
function s.eqlimit(e,c)
	return c==e:GetOwner()
end
