--超越天翔
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从双方墓地的怪兽以及除外中的怪兽之中以1只恐龙族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c93918159.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从双方墓地的怪兽以及除外中的怪兽之中以1只恐龙族怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93918159+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c93918159.target)
	e1:SetOperation(c93918159.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：在墓地或除外状态（若是除外则须表侧表示）的恐龙族怪兽，且可以被特殊召唤
function c93918159.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c93918159.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c93918159.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地或除外状态中是否存在至少1只满足条件的恐龙族怪兽
		and Duel.IsExistingTarget(c93918159.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil,e,tp) end
	-- 向发动效果的玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地或除外状态中选择1只满足条件的恐龙族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c93918159.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含将选中的1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c93918159.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍与当前效果相关联，且不受“王家之谷”等墓地限制效果的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以表侧表示在自己场上特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
