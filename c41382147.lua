--星見鳥ラリス
-- 效果：
-- 这张卡的攻击力在伤害步骤时上升战斗的对方怪兽等级×200的数值。这张卡攻击的场合伤害步骤结束时从游戏中除外，下次自己回合的战斗阶段开始时表侧攻击表示回到自己场上。
function c41382147.initial_effect(c)
	-- 这张卡的攻击力在伤害步骤时上升战斗的对方怪兽等级×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c41382147.atkcon)
	e1:SetValue(c41382147.atkval)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合伤害步骤结束时从游戏中除外，下次自己回合的战斗阶段开始时表侧攻击表示回到自己场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41382147,0))  --"除外"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c41382147.rmcon)
	e2:SetTarget(c41382147.rmtg)
	e2:SetOperation(c41382147.rmop)
	c:RegisterEffect(e2)
end
-- 判断是否处于伤害步骤或伤害计算步骤，并且自身是攻击怪兽或被攻击怪兽，且存在攻击目标。
function c41382147.atkcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断是否为攻击怪兽或被攻击怪兽且攻击目标不为空
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()) and Duel.GetAttackTarget()~=nil
end
-- 返回自身战斗目标等级乘以200的数值作为攻击力加成
function c41382147.atkval(e,c)
	return e:GetHandler():GetBattleTarget():GetLevel()*200
end
-- 判断自身是否参与了战斗且为攻击状态
function c41382147.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否参与了战斗且为攻击状态
	return c:IsRelateToBattle() and c==Duel.GetAttacker() and c:IsFaceup()
end
-- 设置操作信息，表示将自身除外
function c41382147.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 执行除外操作，并注册一个在下次战斗阶段开始时返回场上的效果
function c41382147.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否有效且为表侧表示，并成功将自身除外
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)==1 then
		-- 创建一个在战斗阶段开始时触发的效果，用于将自身返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c41382147.retop)
		-- 将该效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 当轮到自己回合时，将自身返回场上
function c41382147.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	if Duel.GetTurnPlayer()==tp then
		-- 将标记的卡片返回场上
		Duel.ReturnToField(e:GetLabelObject())
	end
end
