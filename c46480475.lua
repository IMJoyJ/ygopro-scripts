--不協和音
-- 效果：
-- 双方玩家不能同调召唤。发动后第3次的自己的结束阶段时这张卡送去墓地。
function c46480475.initial_effect(c)
	-- 发动时点为自由时点，效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46480475.target)
	c:RegisterEffect(e1)
	-- 双方玩家不能同调召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c46480475.splimit)
	c:RegisterEffect(e2)
end
-- 判断是否为同调召唤
function c46480475.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
-- 设置一个持续到自己结束阶段的计数效果
function c46480475.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置计数效果的触发条件和操作
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetLabel(3)
	e1:SetCountLimit(1)
	e1:SetCondition(c46480475.tgcon)
	e1:SetOperation(c46480475.tgop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断是否为自己的回合
function c46480475.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为使用者
	return Duel.GetTurnPlayer()==tp
end
-- 执行计数递减与墓地处理
function c46480475.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	if ct==0 then
		-- 将自身送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
