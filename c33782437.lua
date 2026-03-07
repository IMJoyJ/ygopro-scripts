--一時休戦
-- 效果：
-- ①：双方玩家各自从卡组抽1张。直到下次的对方回合结束时，双方受到的全部伤害变成0。
function c33782437.initial_effect(c)
	-- ①：双方玩家各自从卡组抽1张。直到下次的对方回合结束时，双方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33782437.target)
	e1:SetOperation(c33782437.activate)
	c:RegisterEffect(e1)
end
-- 检查是否可以抽卡
function c33782437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家和对方玩家是否可以各抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置连锁操作信息为双方各抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 执行效果处理，进行抽卡并设置伤害减免效果
function c33782437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前玩家从卡组抽1张卡
	local d1=Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家从卡组抽1张卡
	local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
	if d1==0 or d2==0 then return end
	-- 创建并注册伤害变更效果，使双方受到的伤害变为0；再创建并注册效果伤害减免效果，使双方不受效果伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将伤害变更效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果伤害减免效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
end
