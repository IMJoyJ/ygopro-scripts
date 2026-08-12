--ディアバウンド・カーネル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击宣言时发动。这张卡的攻击力上升600。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降这张卡的攻击力数值。那之后，这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
function c51644030.initial_effect(c)
	-- ①：这张卡的攻击宣言时发动。这张卡的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51644030,0))  --"这张卡的攻击力上升600"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c51644030.atkop1)
	c:RegisterEffect(e1)
	-- ②：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降这张卡的攻击力数值。那之后，这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51644030,1))  --"对方怪兽攻击力下降"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,51644030)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c51644030.atktg)
	e2:SetOperation(c51644030.atkop2)
	c:RegisterEffect(e2)
end
-- 使这张卡的攻击力上升600点。
function c51644030.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡的攻击力增加600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足选择对方场上表侧表示怪兽作为对象的条件。
function c51644030.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return e:GetHandler():IsAbleToRemove() and e:GetHandler():GetAttack()>0
		-- 检索满足条件的对方场上的表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的一只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，将此卡除外作为处理的一部分。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 使选择的对方怪兽攻击力下降，同时将此卡除外。
function c51644030.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsFaceup() then
		local atk=c:GetAttack()
		-- 使目标怪兽的攻击力减少自身攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 中断当前效果处理流程，防止后续效果错时点。
			Duel.BreakEffect()
			-- 以临时除外的方式将此卡移除。
			if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				-- 注册一个在下个准备阶段返回场上的持续效果。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e2:SetCountLimit(1)
				-- 记录当前回合数用于判断是否到准备阶段。
				e2:SetLabel(Duel.GetTurnCount())
				e2:SetLabelObject(c)
				e2:SetCondition(c51644030.retcon)
				e2:SetOperation(c51644030.retop)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				-- 将该持续效果注册给全局环境。
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end
-- 判断是否到达指定的回合准备阶段。
function c51644030.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当当前回合数大于记录的回合数时触发返回效果。
	return Duel.GetTurnCount()>e:GetLabel()
end
-- 将此卡返回到场上。
function c51644030.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从除外状态返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
