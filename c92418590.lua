--ギミック・パペット－ネクロ・ドール
-- 效果：
-- 这个卡名的效果1回合只能使用1次，把这张卡作为超量召唤的素材的场合，不是「机关傀儡」怪兽的超量召唤不能使用。
-- ①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只「机关傀儡」怪兽除外才能发动。这张卡特殊召唤。
function c92418590.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只「机关傀儡」怪兽除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92418590,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,92418590)
	e1:SetCost(c92418590.cost)
	e1:SetTarget(c92418590.target)
	e1:SetOperation(c92418590.operation)
	c:RegisterEffect(e1)
	-- 把这张卡作为超量召唤的素材的场合，不是「机关傀儡」怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetValue(c92418590.xyzlimit)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中除自身以外的「机关傀儡」怪兽，且该卡可以作为发动代价被除外
function c92418590.cfilter(c)
	return c:IsSetCard(0x1083) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 效果发动代价：从自己墓地把这张卡以外的1只「机关傀儡」怪兽除外
function c92418590.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除自身以外、可以作为发动代价除外的「机关傀儡」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92418590.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1张除自身以外的「机关傀儡」怪兽作为发动代价
	local g=Duel.SelectMatchingCard(tp,c92418590.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动目标：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c92418590.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：如果这张卡仍存在于墓地，则将其特殊召唤
function c92418590.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制该卡只能作为「机关傀儡」怪兽的超量召唤素材
function c92418590.xyzlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x1083)
end
