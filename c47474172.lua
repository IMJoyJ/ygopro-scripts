--魔筒覗ベイオネーター
-- 效果：
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降对方场上的怪兽数量×1000。
function c47474172.initial_effect(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降对方场上的怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47474172,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c47474172.atktg)
	e1:SetOperation(c47474172.atkop)
	c:RegisterEffect(e1)
end
-- 发动条件与取对象处理：检测对方场上是否存在表侧表示怪兽可供选择，并让玩家选择1只对方场上的表侧表示怪兽作为效果对象。
function c47474172.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 发动时合法性检查：确认对方场上有1只表侧表示怪兽可以作为效果对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择提示，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽；若对象仍表侧表示且与效果关联，则计算对方场上怪兽数量，使对象攻击力下降该数量×1000。
function c47474172.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取对方场上的怪兽数量，作为攻击力下降的倍数。
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 那只怪兽的攻击力下降对方场上的怪兽数量×1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
