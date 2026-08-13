--輪廻独断
-- 效果：
-- ①：1回合1次，宣言1个种族才能发动。这个回合，双方墓地的怪兽变成宣言的种族。
function c45064756.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，宣言1个种族才能发动。这个回合，双方墓地的怪兽变成宣言的种族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetTarget(c45064756.target)
	e2:SetOperation(c45064756.operation)
	c:RegisterEffect(e2)
end
-- 发动时的效果处理：检查发动条件（无额外限制），提示并宣言1个种族，将宣言的种族记录在效果标签中，并获取双方墓地所有怪兽用于设置操作信息。
function c45064756.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向操作玩家显示“请选择要宣言的种族”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从所有种族中宣言1个种族，返回宣言的种族值。
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	-- 获取双方墓地存在的所有怪兽卡（用于后续操作信息记录，表示该效果会影响这些卡）。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 设置当前连锁的操作信息为“涉及墓地”，对象为所有墓地怪兽，数量为怪兽数量；供王家长眠之谷等卡进行效果互动检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 效果处理时：创建持续到回合结束的场地效果，使双方墓地的怪兽种族变为宣言的种族；若系统支持更专用的墓地种族变更效果（EFFECT_CHANGE_GRAVE_RACE），则再注册一个以玩家为目标的同类效果。两个效果仅在双方均不受王家长眠之谷影响时适用。
function c45064756.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，双方墓地的怪兽变成宣言的种族。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e1:SetValue(e:GetLabel())
	e1:SetCondition(c45064756.condition)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将改变双方墓地怪兽种族的场地效果注册到决斗中，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	if EFFECT_CHANGE_GRAVE_RACE==nil then return end
	-- 这个回合，双方墓地的怪兽变成宣言的种族。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_GRAVE_RACE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(e:GetLabel())
	e2:SetCondition(c45064756.condition)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将专用墓地种族变更效果注册到决斗中，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 判定该效果能否适用：双方玩家都不受王家长眠之谷影响时返回真，否则不适用。
function c45064756.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查发动方玩家是否不受“王家长眠之谷”影响。
	return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY)
		-- 检查对方玩家是否不受“王家长眠之谷”影响。
		and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NECRO_VALLEY)
end
