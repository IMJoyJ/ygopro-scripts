--悪夢の鉄檻
-- 效果：
-- 这张卡发动后继续留在场上，用对方回合计算的2回合后的对方结束阶段破坏。
-- ①：只要这张卡在魔法与陷阱区域存在，怪兽不能攻击。
function c58775978.initial_effect(c)
	-- 这张卡发动后继续留在场上，用对方回合计算的2回合后的对方结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c58775978.target)
	e1:SetOperation(c58775978.activate)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(c58775978.atkcon)
	c:RegisterEffect(e2)
	-- 这张卡发动后继续留在场上
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理：注册在2回合后的对方结束阶段将自身破坏的延迟效果，并注册计数标记
function c58775978.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 用对方回合计算的2回合后的对方结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c58775978.descon)
	e1:SetOperation(c58775978.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	e:GetHandler():RegisterEffect(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2)
	c58775978[e:GetHandler()]=e1
end
-- 卡片发动成功时的效果处理：将自身卡片的回合计数器初始化为0
function c58775978.activate(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():SetTurnCounter(0)
end
-- 破坏效果的触发条件：当前回合是对方的回合
function c58775978.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 破坏效果的具体操作：在对方结束阶段使回合计数器加1，当计数器达到2时，通过规则将自身破坏并清除标记
function c58775978.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 因规则原因破坏这张卡
		Duel.Destroy(c,REASON_RULE)
		c:ResetFlagEffect(1082946)
	end
end
-- 攻击限制效果的适用条件：这张卡在魔法与陷阱区域表侧表示存在（作为魔法卡存在）
function c58775978.atkcon(e)
	return e:GetHandler():GetType()==TYPE_SPELL
end
