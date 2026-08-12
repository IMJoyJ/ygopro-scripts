--EMリバイバル
-- 效果：
-- ①：自己场上的怪兽被战斗·效果破坏的场合才能发动。从自己的手卡·墓地选1只「娱乐伙伴」怪兽特殊召唤。
function c5672432.initial_effect(c)
	-- ①：自己场上的怪兽被战斗·效果破坏的场合才能发动。从自己的手卡·墓地选1只「娱乐伙伴」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c5672432.condition)
	e1:SetTarget(c5672432.target)
	e1:SetOperation(c5672432.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上被战斗或效果破坏的怪兽
function c5672432.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 发动条件：检查被破坏的卡中是否存在满足条件的怪兽
function c5672432.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5672432.cfilter,1,nil,tp)
end
-- 过滤条件：手卡或墓地中可以特殊召唤的「娱乐伙伴」怪兽
function c5672432.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的检测与操作信息设置
function c5672432.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只可以特殊召唤的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c5672432.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：从手卡或墓地特殊召唤1只「娱乐伙伴」怪兽
function c5672432.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的「娱乐伙伴」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c5672432.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
