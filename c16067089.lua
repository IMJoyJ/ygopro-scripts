--蛇神降臨
-- 效果：
-- 自己场上表侧表示存在的「毒蛇王 维诺米隆」被战斗以外破坏时才能发动。从手卡·卡组把1只「毒蛇神 维诺米纳迦」特殊召唤。
function c16067089.initial_effect(c)
	-- 创建效果，设置为魔陷发动，破坏时发动，条件为己方场上表侧表示存在的「毒蛇王 维诺米隆」被战斗以外破坏，目标为从手卡·卡组把1只「毒蛇神 维诺米纳迦」特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c16067089.condition)
	e1:SetTarget(c16067089.target)
	e1:SetOperation(c16067089.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡是否为「毒蛇王 维诺米隆」且上一个控制者为玩家tp，上一个位置为场上，上一个表示形式为正面表示
function c16067089.cfilter(c,tp)
	return c:IsCode(72677437) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 条件函数，检查是否有满足cfilter条件的卡被破坏
function c16067089.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16067089.cfilter,1,nil,tp)
end
-- 过滤函数，检查卡是否为「毒蛇神 维诺米纳迦」且可以被特殊召唤
function c16067089.filter(c,e,tp)
	return c:IsCode(8062132) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 目标函数，检查是否满足特殊召唤条件
function c16067089.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c16067089.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1张手卡或卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 发动函数，检查场上是否有空位，提示选择特殊召唤的卡并执行特殊召唤
function c16067089.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c16067089.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤并完成程序
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
