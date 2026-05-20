--忍の六武
-- 效果：
-- ①：自己场上有「六武众」怪兽6只存在，那些属性全部不同的场合才能发动。下次的对方回合跳过。
function c6357341.initial_effect(c)
	-- ①：自己场上有「六武众」怪兽6只存在，那些属性全部不同的场合才能发动。下次的对方回合跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c6357341.condition)
	e1:SetTarget(c6357341.target)
	e1:SetOperation(c6357341.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「六武众」怪兽
function c6357341.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 发动条件：自己场上有6只表侧表示的「六武众」怪兽，且属性各不相同
function c6357341.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的「六武众」怪兽组
	local g=Duel.GetMatchingGroup(c6357341.filter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetAttribute)==6
end
-- 发动时的效果目标检查
function c6357341.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方是否已经受到跳过回合效果的影响，若已受到影响则不能发动
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN) end
end
-- 效果处理：使对方的下一个回合跳过
function c6357341.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_TURN)
	e1:SetTargetRange(0,1)
	local rct=1
	-- 如果当前正是对方回合，则将重置计数设为2，以确保跳过的是下一个对方回合
	if Duel.GetTurnPlayer()==1-tp then rct=2 end
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,rct)
	-- 向系统注册该跳过回合的全局效果
	Duel.RegisterEffect(e1,tp)
end
