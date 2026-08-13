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
	-- 这个卡名的②的效果1回合只能使用1次。②：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降这张卡的攻击力数值。那之后，这张卡直到下个回合的准备阶段除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51644030,1))  --"对方怪兽攻击力下降"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,51644030)
	-- 设置②效果的发动条件：当前不是伤害步骤，或处于伤害步骤但尚未进行伤害计算，从而允许该效果在伤害步骤的伤害计算前发动（配合EFFECT_FLAG_DAMAGE_STEP）。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(c51644030.atktg)
	e2:SetOperation(c51644030.atkop2)
	c:RegisterEffect(e2)
end
-- ①效果处理：攻击宣言时，若此卡仍表侧表示且与发动效果关联，则为自身赋予攻击力上升600的永续效果，该提升在卡片离场/无效等标准情况下重置。
function c51644030.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的目标设定与发动条件：确认选择对象的合法性（对方场上表侧怪兽），并检查此卡能被除外、当前攻击力大于0，且对方场上有可选取的表侧表示怪兽。
function c51644030.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return e:GetHandler():IsAbleToRemove() and e:GetHandler():GetAttack()>0
		-- 检查对方场上是否存在至少1只表侧表示怪兽，以保证效果可以选取对象并发动。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择提示“请选择表侧表示的卡”，用于选取对方场上的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让当前玩家从对方场上选择1只表侧表示怪兽，并将其设置为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理包含将此卡除外的预定操作（数量1），供其他卡连锁与判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：使对象怪兽攻击力下降此卡当前攻击力数值直到回合结束；若此卡仍有效且对象未持有反转攻击力变化的效果（EFFECT_REVERSE_UPDATE），则中断效果处理，将此卡以暂时除外方式除外，并注册在下个准备阶段返回的处理。
function c51644030.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsFaceup() then
		local atk=c:GetAttack()
		-- 那只怪兽的攻击力直到回合结束时下降这张卡的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 中断当前效果处理，使之后的“除外自己”与之前的“下降攻击力”不在同一时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 以“效果+暂时”的原因将此卡除外；若除外成功，则继续设置下个准备阶段返回的处理。
			if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				-- 那之后，这张卡直到下个回合的准备阶段除外。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
				e2:SetCountLimit(1)
				-- 将当前回合数记录在返回效果的标签中，作为判定“下个回合准备阶段”的依据。
				e2:SetLabel(Duel.GetTurnCount())
				e2:SetLabelObject(c)
				e2:SetCondition(c51644030.retcon)
				e2:SetOperation(c51644030.retop)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				-- 将返回效果注册到当前玩家场上，使其在后续准备阶段满足条件时自动触发。
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end
-- 返回效果的触发条件：当前回合数大于记录的回合数，即已经进入下一个回合。
function c51644030.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否大于记录标签中的回合数，用于确定是否已到下个回合的准备阶段。
	return Duel.GetTurnCount()>e:GetLabel()
end
-- 返回处理：将被暂时除外的这张卡返回到场上。
function c51644030.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标签记录的卡（被暂时除外的此卡）以离场前表示形式返回到场上。
	Duel.ReturnToField(e:GetLabelObject())
end
