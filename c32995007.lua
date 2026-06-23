--天狼王 ブルー・セイリオス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 场上存在的这张卡被破坏送去墓地时，选择对方场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力下降2400。
function c32995007.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 场上存在的这张卡被破坏送去墓地时，选择对方场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力下降2400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32995007,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c32995007.atkcon)
	e1:SetTarget(c32995007.atktg)
	e1:SetOperation(c32995007.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：卡片从场上被破坏送去墓地
function c32995007.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 选择目标：对方场上表侧表示存在的1只怪兽
function c32995007.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上表侧表示存在的1只怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：对目标怪兽的攻击力下降2400
function c32995007.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力下降2400
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
