--混沌なる魅惑の女王
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只其他的光·暗属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。这张卡直到结束阶段当作和这个效果装备的怪兽同名卡使用。这个效果把光·暗属性的怪兽卡装备的场合，可以再从自己的卡组·墓地把1只暗属性「魅惑的女王」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册从手卡弃怪兽特召自身的①效果，以及装备墓地怪兽、复制卡名并可追加特召暗属性「魅惑的女王」的②效果（含二速分支）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。 ①：从手卡把1只其他的光·暗属性怪兽丢弃才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。 ②：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。这个效果把光·暗属性的怪兽卡装备的场合，可以再从自己的卡组·墓地把1只暗属性「魅惑的女王」怪兽特殊召唤。
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
-- 过滤函数，检查是否为手卡中可丢弃的光属性或暗属性怪兽
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsDiscardable()
end
-- 发动代价处理，检查并从手卡选择除自身外的1只光·暗属性怪兽丢弃去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在这张卡以外至少1只可丢弃的光·暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示控制者选择要作为代价丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从自己手卡选择1张除这张卡外的光·暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的手卡作为发动代价丢弃去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 检查自己怪兽区是否有空位且此卡可特殊召唤，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，确认此卡仍与效果关联后将其从手卡表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 发动条件检查，确认此卡未获得二速发动权限时以起动效果形式发动
function s.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否未受到95937545效果影响而无法将此效果二速化
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,95937545)
end
-- 发动条件检查，确认此卡已获得二速发动权限时以诱发即时效果形式发动
function s.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否受到95937545效果影响而能将此效果作为诱发即时效果发动
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,95937545)
end
-- 过滤函数，检查是否为未受禁止宣言且不违反自己场上唯一性限制的怪兽
function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 检查自己魔陷区是否有空位且双方墓地存在可装备怪兽，选择对象并设置操作信息
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc,tp) end
	-- 检查自己魔法与陷阱区域是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己或对方墓地是否存在至少1只可作为对象装备的怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 提示控制者选择墓地要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己或对方墓地1只怪兽作为本次连锁的对象
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	-- 设置将对象怪兽从墓地移动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	if bit.band(g:GetFirst():GetOriginalAttribute(),ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)~=0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(0)
	end
end
-- 过滤函数，检查是否为暗属性「魅惑的女王」且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理，将对象怪兽当作装备魔法卡装备给自身并直到结束阶段变为同名卡，若装备了光·暗属性怪兽可再从卡组·墓地特召1只暗属性「魅惑的女王」怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象选择的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认自身表侧存在且对象怪兽不受王家长眠之谷阻碍，将其作为装备卡装备给自身
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
			-- 检查自己怪兽区是否至少有1个空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己卡组·墓地（受王家长眠之谷过滤）是否存在可特殊召唤的暗属性「魅惑的女王」怪兽
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
			-- 询问控制者是否再从卡组·墓地特殊召唤1只暗属性「魅惑的女王」怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再把怪兽特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤与前面的装备及改名视为不同时处理
			Duel.BreakEffect()
			-- 提示控制者选择要特殊召唤的暗属性「魅惑的女王」怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己卡组·墓地选择1只暗属性「魅惑的女王」怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的暗属性「魅惑的女王」怪兽表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- 装备限制函数，限定该装备卡只能装备给其拥有者（即这张卡）
function s.eqlimit(e,c)
	return c==e:GetOwner()
end
