--ナチュル・クリフ
-- 效果：
-- 这张卡从场上送去墓地时，可以从自己卡组把1只4星以下的名字带有「自然」的怪兽在自己场上表侧攻击表示特殊召唤。
function c33866130.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33866130,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c33866130.spcon)
	e1:SetTarget(c33866130.sptg)
	e1:SetOperation(c33866130.spop)
	c:RegisterEffect(e1)
end
-- 这张卡从场上送去墓地时
function c33866130.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 名字带有「自然」的怪兽
function c33866130.filter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 从自己卡组把1只4星以下的名字带有「自然」的怪兽在自己场上表侧攻击表示特殊召唤
function c33866130.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 满足条件的怪兽数量大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检索满足条件的卡片组
		and Duel.IsExistingMatchingCard(c33866130.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤满足条件的怪兽
function c33866130.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 场上没有可用区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c33866130.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将目标怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
