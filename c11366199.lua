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
	-- 效果作用：设置该效果影响所有玩家。
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
-- 效果作用：限制特殊召唤位置的函数定义。
function c11366199.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 效果作用：除外卡片过滤器函数定义。
function c11366199.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_DARK)
end
-- 效果作用：特殊召唤费用处理函数定义。
function c11366199.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取满足条件的除外卡片组。
	local g=Duel.GetMatchingGroup(c11366199.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE-e:GetHandler():GetLocation(),0,nil)
	-- 效果作用：检查是否满足除外两张符合条件卡片的条件。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_WIND,ATTRIBUTE_DARK) end
	-- 效果作用：向玩家提示选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 效果作用：选择满足条件的两张卡片组成组合。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_WIND,ATTRIBUTE_DARK)
	-- 效果作用：将选中的卡片除外作为费用。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果作用：特殊召唤目标判定函数定义。
function c11366199.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否有足够的怪兽区域进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 效果作用：设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：特殊召唤执行函数定义。
function c11366199.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果作用：将卡片特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
