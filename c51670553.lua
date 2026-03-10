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
-- 筛选有装备卡且装备卡包含「竹光」字段的怪兽
function c51670553.filter(c)
	return c:GetEquipCount()~=0 and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x60)
end
-- 选择效果的对象
function c51670553.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c51670553.filter(chkc) end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c51670553.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	e:GetHandler():SetTurnCounter(0)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c51670553.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将选中的怪兽设置为当前卡的效果对象
function c51670553.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 判断是否满足跳过抽卡阶段的条件
function c51670553.skipcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 确认造成战斗伤害且攻击怪兽或被攻击怪兽为目标怪兽
	return tc and ep~=tp and r==REASON_BATTLE and (Duel.GetAttacker()==tc or Duel.GetAttackTarget()==tc)
end
-- 设置跳过对方抽卡阶段的效果
function c51670553.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置跳过对方抽卡阶段的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	-- 判断当前回合玩家是否为效果使用者
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 将跳过抽卡阶段的效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
-- 准备阶段触发条件判断
function c51670553.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家为效果使用者
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段时计数器加一并判断是否达到2次
function c51670553.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 满足条件时破坏此卡
		Duel.Destroy(c,REASON_RULE)
	end
end
