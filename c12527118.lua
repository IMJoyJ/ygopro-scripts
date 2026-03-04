--カシモラル
-- 效果：
-- ①：这张卡召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升那个原本攻击力数值。这个效果适用的怪兽在下个回合的结束阶段破坏，对方受到那个原本攻击力一半数值的伤害。
-- ②：对方战斗阶段开始时，把通常召唤的这张卡解放才能发动。这个回合，对方怪兽不能直接攻击。
function c12527118.initial_effect(c)
	-- ①：这张卡召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c12527118.atktg)
	e1:SetOperation(c12527118.atkop)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段开始时，把通常召唤的这张卡解放才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c12527118.limcon)
	e2:SetCost(c12527118.limcost)
	e2:SetOperation(c12527118.limop)
	c:RegisterEffect(e2)
end
-- 选择效果的对象
function c12527118.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择对方场上的1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动
function c12527118.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 使对象怪兽的攻击力上升其原本攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(12527118,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 在下个回合的结束阶段破坏对象怪兽，并使对方受到其原本攻击力一半数值的伤害
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetCountLimit(1)
		-- 记录当前回合数用于后续判断
		e2:SetLabel(fid,Duel.GetTurnCount())
		e2:SetLabelObject(tc)
		e2:SetCondition(c12527118.descon)
		e2:SetOperation(c12527118.desop)
		-- 将该效果注册到游戏环境
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否满足破坏条件
function c12527118.descon(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	local tc=e:GetLabelObject()
	-- 判断是否为下个回合且对象怪兽未被其他效果影响
	return Duel.GetTurnCount()~=ct and tc:GetFlagEffectLabel(12527118)==fid
end
-- 执行破坏和伤害处理
function c12527118.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 破坏对象怪兽
	if Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 给予对方伤害
		Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
-- 判断是否满足效果发动条件
function c12527118.limcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合不是自己且此卡为通常召唤
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 准备支付效果的解放费用
function c12527118.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果的发动费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 处理效果的发动
function c12527118.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方怪兽在本回合不能直接攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
