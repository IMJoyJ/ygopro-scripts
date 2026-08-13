--カシモラル
-- 效果：
-- ①：这张卡召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升那个原本攻击力数值。这个效果适用的怪兽在下个回合的结束阶段破坏，对方受到那个原本攻击力一半数值的伤害。
-- ②：对方战斗阶段开始时，把通常召唤的这张卡解放才能发动。这个回合，对方怪兽不能直接攻击。
function c12527118.initial_effect(c)
	-- ①：这张卡召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升那个原本攻击力数值。这个效果适用的怪兽在下个回合的结束阶段破坏，对方受到那个原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c12527118.atktg)
	e1:SetOperation(c12527118.atkop)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段开始时，把通常召唤的这张卡解放才能发动。这个回合，对方怪兽不能直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c12527118.limcon)
	e2:SetCost(c12527118.limcost)
	e2:SetOperation(c12527118.limop)
	c:RegisterEffect(e2)
end
-- 效果①的取对象目标选择函数：在发动时确认可以从对方场上选择表侧表示怪兽，并让玩家选择1只作为对象。
function c12527118.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 效果发动合法性检查（chk==0）：确认对方场上存在至少1只表侧表示怪兽可以作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择效果的对象”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从对方场上的表侧表示怪兽中选择1只作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的发动处理：先取得对象，然后使对象攻击力上升其原本攻击力数值，并注册一个持续效果用于在下个回合的结束阶段破坏对象并给与伤害。
function c12527118.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①发动时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(12527118,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果适用的怪兽在下个回合的结束阶段破坏，对方受到那个原本攻击力一半数值的伤害。②：对方战斗阶段开始时，把通常召唤的这张卡解放才能发动。这个回合，对方怪兽不能直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetCountLimit(1)
		-- 将当前回合数和对象怪兽的战斗位置标识fid存入效果标签，用于在下个回合结束时识别该怪兽并防止误判。
		e2:SetLabel(fid,Duel.GetTurnCount())
		e2:SetLabelObject(tc)
		e2:SetCondition(c12527118.descon)
		e2:SetOperation(c12527118.desop)
		-- 将结束阶段破坏并给予伤害的持续效果注册到该卡控制者场上，使后续结束阶段按条件触发。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 持续效果的发动条件函数：确认已到下一个回合（回合数已变化）且对象怪兽仍带有对应标记。
function c12527118.descon(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	local tc=e:GetLabelObject()
	-- 判断当前回合数是否不等于记录的上次回合数，且对象怪兽仍保有卡西莫拉尔赋予的标记，以确认执行破坏与伤害。
	return Duel.GetTurnCount()~=ct and tc:GetFlagEffectLabel(12527118)==fid
end
-- 持续效果处理函数：破坏被标记的怪兽，若破坏成功则给与对方该怪兽原本攻击力一半数值的伤害。
function c12527118.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因破坏对象怪兽，并判断破坏是否成功（成功则继续伤害处理）。
	if Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 给与对方玩家对象怪兽原本攻击力一半数值的伤害。
		Duel.Damage(1-tp,math.floor(tc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
-- 效果②的发动条件函数：当前为对方回合的战斗阶段开始时，且这张卡是通常召唤成功出场。
function c12527118.limcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是这张卡的控制者/持有者（即对方回合），且这张卡的召唤类型为通常召唤。
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 效果②的发动代价函数：确认这张卡可以被解放，满足代价条件。
function c12527118.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 作为发动代价，解放这张卡自身。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的处理：为对方场上的怪兽附加“不能直接攻击”的限制效果，持续到这个回合结束。
function c12527118.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“对方怪兽不能直接攻击”的效果注册到场上，使该限制适用于对方场上的怪兽直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
