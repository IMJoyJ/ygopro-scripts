--ダーク・シムルグ
-- 效果：
-- ①：这张卡在手卡存在的场合，从自己墓地把暗属性和风属性的怪兽各1只除外才能发动。这张卡特殊召唤。
-- ②：这张卡在墓地存在的场合，从手卡把暗属性和风属性的怪兽各1只除外才能发动。这张卡特殊召唤。
-- ③：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
-- ④：只要这张卡在怪兽区域存在，对方不能把卡盖放。
function c11366199.initial_effect(c)
	-- ③：只要这张卡在怪兽区域存在，这张卡的属性也当作「风」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_WIND)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在的场合，从自己墓地把暗属性和风属性的怪兽各1只除外才能发动。这张卡特殊召唤。②：这张卡在墓地存在的场合，从手卡把暗属性和风属性的怪兽各1只除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11366199,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCost(c11366199.spcost)
	e2:SetTarget(c11366199.sptg)
	e2:SetOperation(c11366199.spop)
	c:RegisterEffect(e2)
	-- ④：只要这张卡在怪兽区域存在，对方不能把卡盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_MSET)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	-- 设置该效果的适用对象为任意卡，使“不能覆盖怪兽”的限制对对方所有要盖放的怪兽都生效。
	e4:SetTarget(aux.TRUE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e7:SetTarget(c11366199.sumlimit)
	c:RegisterEffect(e7)
end
-- 作为特殊召唤表示形式的限制条件：若即将进行的特殊召唤的表示形式包含里侧表示，则返回真，从而禁止对方以里侧表示特殊召唤怪兽。
function c11366199.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 代价筛选函数：要求卡可以从当前场所除外作为代价，且属性为暗属性或风属性。
function c11366199.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_DARK)
end
-- 代价的确认与执行：先获取可作代价的候选怪兽组，确认阶段判断能否选出暗、风属性怪兽各1只；实际发动时提示玩家选择这2张卡并除外作为代价。
function c11366199.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取候选代价怪兽组：从手卡或墓地中排除这张卡当前所在位置后的区域，筛选出可除外且暗属性或风属性的怪兽。
	local g=Duel.GetMatchingGroup(c11366199.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE-e:GetHandler():GetLocation(),0,nil)
	-- 若为代价确认阶段，检查候选组中能否选出2张怪兽，使其中一张为暗属性、另一张为风属性（即暗、风属性各1只）。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_WIND,ATTRIBUTE_DARK) end
	-- 向当前玩家显示选择操作的提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从候选组中选出2张满足暗、风属性各1只的怪兽卡；若选择不合法则重新选择，最终返回选中的卡组。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_WIND,ATTRIBUTE_DARK)
	-- 将选中的2张怪兽卡以表侧表示除外，作为这张卡特殊召唤效果的发动代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的发动条件与目标确认：检查己方主要怪兽区域是否有空位，且这张卡本身是否可以被特殊召唤；若满足则登记特殊召唤操作信息。
function c11366199.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时确认己方主要怪兽区域存在可用的空格，保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次效果要特殊召唤的这张卡登记到连锁处理信息中（类别为特殊召唤），以便其他卡对此进行响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果结算：确认这张卡仍与该效果关联（未因离场等原因失去联系），若仍有联系则将其特殊召唤。
function c11366199.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到发动者场上；不检查召唤条件且不检查苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
