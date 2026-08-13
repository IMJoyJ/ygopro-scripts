--H・C スパルタス
-- 效果：
-- 1回合1次，对方怪兽的攻击宣言时选择这张卡以外的自己场上1只名字带有「英豪」的怪兽才能发动。这张卡的攻击力直到战斗阶段结束时上升选择的怪兽的原本攻击力数值。
function c50491121.initial_effect(c)
	-- 对应卡片效果原文：‘1回合1次，对方怪兽的攻击宣言时选择这张卡以外的自己场上1只名字带有「英豪」的怪兽才能发动。这张卡的攻击力直到战斗阶段结束时上升选择的怪兽的原本攻击力数值。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50491121,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetCondition(c50491121.atkcon)
	e1:SetTarget(c50491121.atktg)
	e1:SetOperation(c50491121.atkop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：判断当前是否为对方回合，即对方怪兽进行攻击宣言时才满足发动条件。
function c50491121.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是效果持有者tp，则返回true，表示是对方回合，攻击宣言来自对方怪兽。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义选择对象的过滤条件：该怪兽为表侧表示，且卡名含有「英豪」（字段0x6f）。
function c50491121.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 定义效果发动时的目标选择处理：从自己场上表侧表示的名字带有「英豪」的怪兽中，选择这张卡以外的1只作为对象。
function c50491121.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50491121.filter(chkc) end
	-- 在发动时检查自己场上是否存在1只满足过滤条件且不是这张卡的「英豪」怪兽，以判断是否能够发动。
	if chk==0 then return Duel.IsExistingTarget(c50491121.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示提示信息，要求选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只满足条件的「英豪」怪兽，并将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,c50491121.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：以选择的怪兽的原本攻击力数值为上升值，为这张卡赋予攻击力上升效果，该效果持续到战斗阶段结束。
function c50491121.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 对应卡片效果原文：‘这张卡的攻击力直到战斗阶段结束时上升选择的怪兽的原本攻击力数值。’
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
