--不協和音
-- 效果：
-- 双方玩家不能同调召唤。发动后第3次的自己的结束阶段时这张卡送去墓地。
function c46480475.initial_effect(c)
	-- 发动后第3次的自己的结束阶段时这张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46480475.target)
	c:RegisterEffect(e1)
	-- 双方玩家不能同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c46480475.splimit)
	c:RegisterEffect(e2)
end
-- 过滤条件：若特殊召唤的召唤类型属于同调召唤（sumtp包含SUMMON_TYPE_SYNCHRO），则返回true，禁止该次特殊召唤。
function c46480475.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
-- 发动时的目标处理：无发动条件限制；发动成功后立即注册一个持续效果，用于在每次自己的结束阶段执行自毁倒计时（初始计数3），实现“发动后第3次自己的结束阶段送去墓地”。
function c46480475.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 发动后第3次的自己的结束阶段时这张卡送去墓地。
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
-- 触发条件：当前回合玩家为这张卡的发动者（自己）时返回true，保证只在发动者的结束阶段递减计数。
function c46480475.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于这张卡片的发动者tp，即是否是自己的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 自毁倒计时的操作：将计数标签值减1；当计数归零时，将这张卡送去墓地。
function c46480475.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	if ct==0 then
		-- 以效果原因将这张卡（不协和音）送去墓地，即效果处理完毕自毁。
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end
