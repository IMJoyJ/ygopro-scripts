--死者所生
-- 效果：
-- ①：怪兽被战斗破坏的回合，从手卡·卡组把1张「死者苏生」送去墓地，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽当作「死者苏生」的效果的特殊召唤在自己场上特殊召唤。
function c54564198.initial_effect(c)
	-- ①：怪兽被战斗破坏的回合，从手卡·卡组把1张「死者苏生」送去墓地，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽当作「死者苏生」的效果的特殊召唤在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c54564198.condition)
	e1:SetCost(c54564198.cost)
	e1:SetTarget(c54564198.target)
	e1:SetOperation(c54564198.activate)
	c:RegisterEffect(e1)
	if not c54564198.global_check then
		c54564198.globle_check=true
		-- ①：怪兽被战斗破坏的回合，从手卡·卡组把1张「死者苏生」送去墓地，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽当作「死者苏生」的效果的特殊召唤在自己场上特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(c54564198.checkop)
		-- 注册全局环境效果，用于监测怪兽被战斗破坏的时点
		Duel.RegisterEffect(ge1,0)
	end
end
-- 怪兽被战斗破坏时的处理函数，用于注册回合内有效的标识效果
function c54564198.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家0注册一个在回合结束时重置的标识效果，表示本回合有怪兽被战斗破坏
	Duel.RegisterFlagEffect(0,54564198,RESET_PHASE+PHASE_END,0,1)
end
-- 效果发动条件函数：检查本回合是否有怪兽被战斗破坏
function c54564198.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在怪兽被战斗破坏的全局标识效果
	return Duel.GetFlagEffect(0,54564198)~=0
end
-- 过滤条件：卡名为「死者苏生」且能送去墓地
function c54564198.cfilter(c)
	return c:IsCode(83764718) and c:IsAbleToGraveAsCost()
end
-- 效果发动代价函数：从手卡或卡组将1张「死者苏生」送去墓地
function c54564198.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡或卡组是否存在可以送去墓地的「死者苏生」
	if chk==0 then return Duel.IsExistingMatchingCard(c54564198.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或卡组选择1张「死者苏生」
	local g=Duel.SelectMatchingCard(tp,c54564198.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：可以当作「死者苏生」的效果特殊召唤的怪兽
function c54564198.tgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_MONSTER_REBORN,tp,false,false)
end
-- 效果发动目标函数：选择双方墓地中1只可以特殊召唤的怪兽为对象
function c54564198.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c54564198.tgfilter(chkc,e,tp) and chkc:IsLocation(LOCATION_GRAVE) end
	-- 在发动阶段，检查双方墓地是否存在可特殊召唤的怪兽，且自己场上有可用的怪兽区域
	if chk==0 then return Duel.IsExistingTarget(c54564198.tgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择双方墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54564198.tgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表示该效果包含特殊召唤选定对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将作为对象的怪兽当作「死者苏生」的效果在自己场上特殊召唤
function c54564198.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽当作「死者苏生」的效果在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_VALUE_MONSTER_REBORN,tp,tp,false,false,POS_FACEUP)
	end
end
