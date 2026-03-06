--アーマード・シャーク
-- 效果：
-- 这个卡名在规则上也当作「铠装超量」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组把1只水属性超量怪兽送去墓地，以持有和那个阶级数值相同等级的自己墓地1只鱼族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：对方回合，这张卡在墓地存在的场合，以自己场上1只水属性超量怪兽为对象才能发动。这张卡当作攻击力上升500的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 创建两个效果，分别为①特殊召唤效果和②装备效果
function s.initial_effect(c)
	-- ①：从额外卡组把1只水属性超量怪兽送去墓地，以持有和那个阶级数值相同等级的自己墓地1只鱼族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，这张卡在墓地存在的场合，以自己场上1只水属性超量怪兽为对象才能发动。这张卡当作攻击力上升500的装备魔法卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 设置特殊召唤效果的费用为无费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数，用于判断额外卡组中是否存在满足条件的水属性超量怪兽，且其阶级数值对应墓地中的鱼族怪兽
function s.tgfilter(c,e,tp)
	-- 满足条件的水属性超量怪兽必须能作为特殊召唤目标
	return c:IsAbleToGraveAsCost() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetRank())
end
-- 过滤函数，用于判断墓地中的鱼族怪兽是否满足特殊召唤条件
function s.spfilter(c,e,tp,rk)
	return c:IsFaceup() and c:IsLevel(rk) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件和处理流程，包括选择送去墓地的超量怪兽和目标鱼族怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否存在满足条件的水属性超量怪兽
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的水属性超量怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	-- 将选中的超量怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	local rk=g:GetFirst():GetRank()
	e:SetLabel(rk)
	-- 提示玩家选择要特殊召唤的鱼族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的鱼族怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,rk)
	-- 设置操作信息，表示将特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果的发动，将目标怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且未被王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置装备效果的发动条件，仅在对方回合时可发动
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于判断场上是否存在满足条件的水属性超量怪兽
function s.eqfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
-- 设置装备效果的发动条件和处理流程，包括选择装备对象
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 检查场上是否存在可用的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在满足条件的水属性超量怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的水属性超量怪兽作为装备对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示该卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理装备效果的发动，将该卡装备给目标怪兽并设置攻击力加成
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备卡和目标怪兽是否有效且未被王家长眠之谷影响
	if aux.NecroValleyFilter()(c) and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 执行装备操作，将该卡装备给目标怪兽
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备限制效果，防止该卡被其他卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备后的攻击力加成效果，使装备怪兽攻击力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制效果的判断函数，确保只能装备给指定目标怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
