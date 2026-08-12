--幻蝶の刺客アゲハ
-- 效果：
-- 这张卡以外的自己场上的怪兽给与对方基本分战斗伤害时，选择对方场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力下降那个时候给与的伤害的数值。
function c79972330.initial_effect(c)
	-- 这张卡以外的自己场上的怪兽给与对方基本分战斗伤害时，选择对方场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力下降那个时候给与的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79972330,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c79972330.atcon)
	e1:SetTarget(c79972330.attg)
	e1:SetOperation(c79972330.atop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：受到战斗伤害的是对方，且造成伤害的怪兽是自己场上除这张卡以外的怪兽。
function c79972330.atcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return ep~=tp and rc~=e:GetHandler() and rc:IsControler(tp)
end
-- 判断是否能选择合法对象，并让玩家选择对方场上表侧表示的1只怪兽作为效果对象。
function c79972330.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向玩家发送提示信息，提示选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上表侧表示的1只怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍在场上表侧表示存在，则使其攻击力下降该次战斗伤害的数值。
function c79972330.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力下降那个时候给与的伤害的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
