--代打バッター
-- 效果：
-- ①：这张卡从自己场上送去墓地时才能发动。从手卡把1只昆虫族怪兽特殊召唤。
function c26185991.initial_effect(c)
	-- ①：这张卡从自己场上送去墓地时才能发动。从手卡把1只昆虫族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26185991,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c26185991.condition)
	e1:SetTarget(c26185991.target)
	e1:SetOperation(c26185991.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否从自己的场上送去墓地
function c26185991.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤手卡中满足条件的昆虫族怪兽
function c26185991.filter(c,e,sp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 判断是否满足发动条件
function c26185991.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c26185991.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数
function c26185991.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,c26185991.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
