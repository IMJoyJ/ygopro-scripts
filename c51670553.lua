--魂を吸う竹光
-- 效果：
-- 选择名字带有「竹光」的装备魔法卡所装备给的1只怪兽才能发动。选择的怪兽给与对方基本分战斗伤害的场合，下次的对方的抽卡阶段跳过。这张卡在发动后第2次的自己的准备阶段时破坏。
function c51670553.initial_effect(c)
	-- 选择名字带有「竹光」的装备魔法卡所装备给的1只怪兽才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c51670553.target)
	e1:SetOperation(c51670553.operation)
	c:RegisterEffect(e1)
	-- 选择的怪兽给与对方基本分战斗伤害的场合，下次的对方的抽卡阶段跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51670553,0))  --"跳过抽卡阶段"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(c51670553.skipcon)
	e2:SetOperation(c51670553.skipop)
	c:RegisterEffect(e2)
	-- 这张卡在发动后第2次的自己的准备阶段时破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c51670553.descon)
	e3:SetOperation(c51670553.desop)
	c:RegisterEffect(e3)
end
-- 检查怪兽是否装备着名字带有「竹光」的装备魔法卡（存在系列编号0x60的装备卡），用于筛选可作为效果对象的怪兽。
function c51670553.filter(c)
	return c:GetEquipCount()~=0 and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x60)
end
-- 发动时的目标选择处理：校验对象合法性、检查是否存在可选的怪兽，若可以发动则将本卡回合计数器初始化为0，并提示玩家选择1只装备着「竹光」装备魔法卡的怪兽作为对象。
function c51670553.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51670553.filter(chkc) end
	-- 发动判定：检查双方怪兽区是否存在至少1只满足条件的怪兽，作为能否发动的前提。
	if chk==0 then return Duel.IsExistingTarget(c51670553.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	e:GetHandler():SetTurnCounter(0)
	-- 向操作玩家发送选择对象的提示消息（HINTMSG_TARGET），以便进行目标选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 令玩家从双方怪兽区选择1只符合条件的怪兽，并将其登记为本连锁的效果对象。
	Duel.SelectTarget(tp,c51670553.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象怪兽仍表侧表示且与效果关联有效，则用这张卡将其锁定为永续对象，以便后续监测其造成的战斗伤害。
function c51670553.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本连锁中记录的第一个（也是唯一一个）效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 跳过抽卡阶段的触发条件判定：存在锁定的对象怪兽，且对方受到战斗伤害，并且该对象怪兽是造成该伤害的战斗攻击者或被攻击者。
function c51670553.skipcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 返回触发条件是否成立：存在对象、受伤方为对方、伤害为战斗伤害、该对象怪兽参与本次战斗。
	return tc and ep~=tp and r==REASON_BATTLE and (Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc)
end
-- 当触发条件满足时，创建一个针对对方玩家的跳过抽卡阶段效果（EFFECT_SKIP_DP），根据当前回合决定其持续到第几个对方回合结束，并注册该效果使其生效。
function c51670553.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方的抽卡阶段跳过。这张卡在发动后第2次的自己的准备阶段时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 判断当前回合玩家是否为本卡的控制者，以确定跳过抽卡阶段效果应在第一个还是第二个对方回合结束时重置。
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 将创建的跳过对方抽卡阶段效果注册进决斗，使其开始对对方生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自我破坏的触发条件判定：仅在持有者（控制者）的准备阶段时才允许进行回合计数/破坏处理。
function c51670553.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为本卡控制者，实现在自己的准备阶段才触发计数。
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段处理：将本卡的回合计数器加1；当计数器达到2时，以规则原因将其破坏。
function c51670553.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 以规则原因破坏这张卡，实现‘发动后第2次的自己的准备阶段时破坏’的规则处理。
		Duel.Destroy(c,REASON_RULE)
	end
end
