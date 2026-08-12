--霞の谷の神風
-- 效果：
-- 自己场上表侧表示存在的风属性怪兽回到手卡的场合，可以从自己卡组把1只4星以下的风属性怪兽特殊召唤。这个效果1回合只能使用1次。
function c15854426.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，当自己场上表侧表示存在的风属性怪兽回到手卡时发动，效果类型为场地魔法，触发事件是怪兽回到手牌，限制每回合只能发动一次，效果描述为特殊召唤，分类为特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15854426,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1)
	e2:SetCondition(c15854426.condition)
	e2:SetTarget(c15854426.target)
	e2:SetOperation(c15854426.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断一张怪兽卡是否满足条件：回到手牌前控制者是自己、位置在主要怪兽区、属性为风、且处于正面表示状态。
function c15854426.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 条件函数，判断是否有满足cfilter条件的怪兽回到手牌。
function c15854426.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15854426.cfilter,1,nil,tp)
end
-- 过滤函数，用于筛选满足条件的风属性怪兽：等级不超过4星、属性为风、可以被特殊召唤。
function c15854426.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数，检查是否满足发动条件：自己场上存在空位、当前不在连锁中、卡组中存在满足条件的怪兽。
function c15854426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位，用于判断是否可以发动特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查卡组中是否存在满足条件的怪兽，用于判断是否可以发动特殊召唤。
		and Duel.IsExistingMatchingCard(c15854426.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽，目标为自己的卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，检查场上是否有空位，若有则提示选择并特殊召唤满足条件的怪兽。
function c15854426.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c15854426.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
