--エレキトンボ
-- 效果：
-- 这张卡被对方破坏的场合，可以从自己卡组把1只名字带有「电气」的怪兽特殊召唤。
function c97885363.initial_effect(c)
	-- 这张卡被对方破坏的场合，可以从自己卡组把1只名字带有「电气」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97885363,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c97885363.condition)
	e1:SetTarget(c97885363.target)
	e1:SetOperation(c97885363.operation)
	c:RegisterEffect(e1)
end
-- 检查是否是被对方破坏，且被破坏前由自己控制
function c97885363.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 过滤卡组中名字带有「电气」且可以特殊召唤的怪兽
function c97885363.filter(c,e,tp)
	return c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数
function c97885363.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只满足过滤条件的「电气」怪兽
		and Duel.IsExistingMatchingCard(c97885363.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c97885363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只满足过滤条件的「电气」怪兽
	local g=Duel.SelectMatchingCard(tp,c97885363.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
