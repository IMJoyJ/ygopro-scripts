--スクランブル・エッグ
-- 效果：
-- ①：自己场上的怪兽被战斗·效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「小走鹃」特殊召唤。
function c75078585.initial_effect(c)
	-- ①：自己场上的怪兽被战斗·效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「小走鹃」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c75078585.condition)
	e1:SetTarget(c75078585.target)
	e1:SetOperation(c75078585.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为自己场上因战斗或效果破坏并送去墓地的怪兽
function c75078585.cfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 发动条件：送去墓地的卡片中存在满足上述过滤条件的怪兽
function c75078585.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c75078585.cfilter,1,nil,tp)
end
-- 过滤条件：卡名为「小走鹃」且可以被特殊召唤
function c75078585.filter(c,e,tp)
	return c:IsCode(36472900) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与检测
function c75078585.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡、卡组、墓地是否存在至少1只可以特殊召唤的「小走鹃」
		and Duel.IsExistingMatchingCard(c75078585.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息，表示该效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理的执行函数
function c75078585.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果自己场上没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡、卡组、墓地中选择1只满足条件且不受「王家长眠之谷」影响的「小走鹃」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75078585.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
