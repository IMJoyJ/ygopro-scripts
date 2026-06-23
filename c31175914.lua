--アタック・ゲイナー
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
function c31175914.initial_effect(c)
	-- 诱发效果：这张卡作为同调召唤的素材送去墓地的场合，对方场上表侧表示存在的1只怪兽的攻击力直到结束阶段时下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31175914,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c31175914.atkcon)
	e1:SetTarget(c31175914.atktg)
	e1:SetOperation(c31175914.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在墓地且因同调召唤被送入墓地
function c31175914.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 选择目标：选择对方场上1只表侧表示的怪兽
function c31175914.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示选择对象：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使选择的对方怪兽攻击力下降1000
function c31175914.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力下降1000，直到结束阶段
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
	end
end
