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
		c54564198.global_check=true
		-- ①：怪兽被战斗破坏的回合，
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(c54564198.checkop)
		-- 为双方注册全局辅助连续效果ge1，用于监听战斗破坏怪兽事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监听效果的处理函数，每当发生怪兽被战斗破坏事件时为玩家0注册持续到回合结束的标识效果
function c54564198.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家0注册编号为54564198、在回合结束阶段重置的全局标识效果，标记本回合有怪兽被战斗破坏
	Duel.RegisterFlagEffect(0,54564198,RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的Condition函数，检查本回合是否曾发生过怪兽被战斗破坏
function c54564198.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查编号为54564198的全局标识效果数量是否不为0
	return Duel.GetFlagEffect(0,54564198)~=0
end
-- Cost过滤函数，筛选卡号为「死者苏生」(83764718)且能作为cost送去墓地的卡
function c54564198.cfilter(c)
	return c:IsCode(83764718) and c:IsAbleToGraveAsCost()
end
-- ①效果的Cost函数，从自己手卡·卡组选择1张「死者苏生」送去墓地作为发动代价
function c54564198.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检测时，检查自己手卡·卡组是否存在至少1张满足cfilter条件的「死者苏生」
	if chk==0 then return Duel.IsExistingMatchingCard(c54564198.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 向自己发送选择提示信息：“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让自己在自己卡组·手卡中选择1张满足cfilter条件的「死者苏生」
	local g=Duel.SelectMatchingCard(tp,c54564198.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	-- 将选中的「死者苏生」作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，筛选能以「死者苏生」特殊召唤标识(SUMMON_VALUE_MONSTER_REBORN)特殊召唤的怪兽
function c54564198.tgfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_MONSTER_REBORN,tp,false,false)
end
-- ①效果的Target函数，检查怪兽区空格并从双方墓地选择1只可特招的怪兽作为对象，设置特殊召唤操作信息
function c54564198.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c54564198.tgfilter(chkc,e,tp) and chkc:IsLocation(LOCATION_GRAVE) end
	-- 发动条件检测时，检查双方墓地是否存在至少1只满足tgfilter且可作为对象的怪兽，且自己怪兽区有可用空格
	if chk==0 then return Duel.IsExistingTarget(c54564198.tgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
	-- 向自己发送选择提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己在自己或对方的墓地中选择1只满足tgfilter条件的怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,c54564198.tgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，声明将特殊召唤对象卡g中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的Operation函数，确认对象卡与效果关联后，将其当作「死者苏生」的效果特殊召唤到自己场上
function c54564198.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的第1张对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以「死者苏生」的特殊召唤标识(SUMMON_VALUE_MONSTER_REBORN)将对象怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,SUMMON_VALUE_MONSTER_REBORN,tp,tp,false,false,POS_FACEUP)
	end
end
