--ストーンヘンジ・メソッド
-- 效果：
-- 自己场上的名字带有「先史遗产」的怪兽被战斗或者卡的效果破坏送去墓地时才能发动。从卡组把1只4星以下的名字带有「先史遗产」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽不能把表示形式变更。
function c86555018.initial_effect(c)
	-- 自己场上的名字带有「先史遗产」的怪兽被战斗或者卡的效果破坏送去墓地时才能发动。从卡组把1只4星以下的名字带有「先史遗产」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c86555018.condition)
	e1:SetTarget(c86555018.target)
	e1:SetOperation(c86555018.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查被破坏的卡是否在墓地、原本由自己控制、原本在怪兽区域，且是名字带有「先史遗产」的怪兽
function c86555018.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSetCard(0x70) and c:IsType(TYPE_MONSTER)
end
-- 发动条件：检查被破坏的卡中是否存在满足条件的卡
function c86555018.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86555018.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中4星以下、名字带有「先史遗产」且可以表侧守备表示特殊召唤的怪兽
function c86555018.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标选择与检测
function c86555018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c86555018.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c86555018.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c86555018.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 尝试将选中的怪兽以表侧守备表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽不能把表示形式变更。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的流程处理
	Duel.SpecialSummonComplete()
end
