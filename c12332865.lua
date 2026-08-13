--聖座天嗣ストン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：原本的种族·属性是天使族·地属性的怪兽从自己的手卡·场上送去墓地的场合才能发动。这张卡从手卡特殊召唤。
function c12332865.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：原本的种族·属性是天使族·地属性的怪兽从自己的手卡·场上送去墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12332865,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12332865)
	e1:SetCondition(c12332865.condition)
	e1:SetTarget(c12332865.target)
	e1:SetOperation(c12332865.operation)
	c:RegisterEffect(e1)
end
-- 筛选送去墓地的怪兽：要求其原本属性为地属性、原本种族为天使族，且之前的位置是手卡或怪兽区，并且之前控制者是发动者（tp）。
function c12332865.filter(c,tp)
	return c:GetOriginalAttribute()==ATTRIBUTE_EARTH and c:GetOriginalRace()==RACE_FAIRY
		and c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 发动条件判定：本次被送去墓地的怪兽集合（eg）中存在至少1只满足filter筛选条件的怪兽。
function c12332865.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c12332865.filter,1,nil,tp)
end
-- 效果发动时的处理：在发动确认阶段检查自己场上是否有空余的主要怪兽区，且此卡是否能够被特殊召唤；若满足则登记特殊召唤的操作信息。
function c12332865.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动确认（chk==0），首先要求自己场上存在空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本效果将把此卡特殊召唤，类别为特殊召唤，对象为此卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：如果这张卡仍与该效果关联，则将其以表侧表示特殊召唤到自己的场上。
function c12332865.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到发动者tp的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
