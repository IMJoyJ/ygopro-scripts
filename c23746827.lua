--億年の氷墓
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，对方怪兽的效果用除破坏以外的方法让自己场上的怪兽从场上离开的场合，可以从以下效果选择1个发动。
-- ●这次主要阶段结束。
-- ●下次的对方回合的主要阶段1跳过。
local s,id,o=GetID()
-- 注册卡牌效果：设置为发动时的效果，触发条件为对方怪兽离开场上的场合，限制1回合1次
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c) e1:SetDescription(aux.Stringid(id,0)) e1:SetType(EFFECT_TYPE_ACTIVATE) e1:SetCode(EVENT_LEAVE_FIELD) e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH) e1:SetProperty(EFFECT_FLAG_DELAY) e1:SetCondition(s.condition) e1:SetTarget(s.target) e1:SetOperation(s.operation) c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的怪兽：怪兽从场上离开，且是对方怪兽的效果导致，且不是因破坏离开，且是对方怪兽的效果
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and not c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():IsActiveType(TYPE_MONSTER)
		and c:GetReasonPlayer()==1-tp
end
-- 判断发动条件：当前阶段为主要阶段1或主要阶段2，且有满足条件的怪兽离开场上的情况
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and eg:IsExists(s.filter,1,nil,tp)
end
-- 设置选择效果：让玩家从两个效果中选择一个，分别是“这次主要阶段结束”和“下次的对方回合的主要阶段1跳过”
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 选择效果选项
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"这次主要阶段结束/下次的对方回合的主要阶段1跳过"
	e:SetLabel(op)
end
-- 执行选择的效果：若选择0则跳过当前主要阶段，若选择1则跳过下次对方回合的主要阶段1
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		s.endthism1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.skipnxtm1(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 跳过当前主要阶段：获取当前阶段并跳过该阶段
function s.endthism1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 跳过指定玩家的当前阶段
	Duel.SkipPhase(Duel.GetTurnPlayer(),ph,RESET_PHASE+ph,1)
end
-- 设置跳过下次对方回合主要阶段1的效果：创建一个影响对方玩家的永续效果，使其跳过主要阶段1
function s.skipnxtm1(e,tp,eg,ep,ev,re,r,rp)
	-- local e1=Effect.CreateEffect(e:GetHandler()) e1:SetType(EFFECT_TYPE_FIELD) e1:SetCode(EFFECT_SKIP_M1) e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET) e1:SetTargetRange(0,1) if Duel.GetTurnPlayer()==1-tp then e1:SetLabel(Duel.GetTurnCount()) e1:SetCondition(s.skipcon) e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2) else e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN) end Duel.RegisterEffect(e1,tp) end function s.skipcon(e) return Duel.GetTurnCount()~=e:GetLabel() end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_M1)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断是否为对方回合
	if Duel.GetTurnPlayer()==1-tp then
		-- 记录当前回合数用于条件判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN) end
	-- 注册效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置跳过主要阶段1的条件：当回合数不等于记录的回合数时生效
function s.skipcon(e)
	-- 返回当前回合数与记录回合数是否不同
	return Duel.GetTurnCount()~=e:GetLabel()
end
