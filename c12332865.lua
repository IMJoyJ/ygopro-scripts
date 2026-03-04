--聖座天嗣ストン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：原本的种族·属性是天使族·地属性的怪兽从自己的手卡·场上送去墓地的场合才能发动。这张卡从手卡特殊召唤。
function c12332865.initial_effect(c)
	-- 效果原文内容：①：原本的种族·属性是天使族·地属性的怪兽从自己的手卡·场上送去墓地的场合才能发动。这张卡从手卡特殊召唤。
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
-- 检索满足条件的怪兽组，条件为：原本属性为地属性且原本种族为天使族，且之前位置在手卡或场上，且之前控制者为玩家。
function c12332865.filter(c,tp)
	return c:GetOriginalAttribute()==ATTRIBUTE_EARTH and c:GetOriginalRace()==RACE_FAIRY
		and c:IsPreviousLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 判断是否有满足filter条件的怪兽被送去墓地。
function c12332865.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c12332865.filter,1,nil,tp)
end
-- 设置效果处理时的连锁操作信息，确定将要特殊召唤此卡。
function c12332865.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁将要处理的特殊召唤操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行将此卡特殊召唤的操作。
function c12332865.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
