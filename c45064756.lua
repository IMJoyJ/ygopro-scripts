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
-- 选择要宣言的种族并设置效果参数
function c45064756.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家提示“请选择要宣言的种族”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	-- 获取双方墓地中的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	-- 设置连锁操作信息，标明将要处理的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 设置种族变更效果，使墓地怪兽变为宣言的种族
function c45064756.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册改变种族的效果到场上
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e1:SetValue(e:GetLabel())
	e1:SetCondition(c45064756.condition)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
	if EFFECT_CHANGE_GRAVE_RACE==nil then return end
	-- 注册额外的墓地种族变更效果以确保双方墓地怪兽都改变种族
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_GRAVE_RACE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetValue(e:GetLabel())
	e2:SetCondition(c45064756.condition)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否受到王家长眠之谷影响
function c45064756.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 判断发动玩家是否受到王家长眠之谷影响
	return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NECRO_VALLEY)
		-- 判断对方玩家是否受到王家长眠之谷影响
		and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_NECRO_VALLEY)
end
