--A・ジェネクス・チェンジャー
-- 效果：
-- ①：1回合1次，以场上1只表侧表示怪兽为对象，宣言1个属性才能发动。那只怪兽直到回合结束时变成宣言的属性。
function c20127343.initial_effect(c)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象，宣言1个属性才能发动。那只怪兽直到回合结束时变成宣言的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20127343,0))  --"属性变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c20127343.costg)
	e1:SetOperation(c20127343.cosop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与属性宣言处理函数：先检查是否存在可选的表侧表示怪兽；存在则选择1只对象，并让玩家宣言1个属性；将宣言的属性记录在效果标签中供处理时使用。
function c20127343.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：场上是否存在至少1只表侧表示怪兽可以作为效果对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择表侧表示的卡”的提示，引导玩家选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方场上表侧表示怪兽中选择1只作为效果对象，并记录为该连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 给玩家显示“请选择要宣言的属性”的提示，引导玩家宣言属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性，可选项排除对象怪兽当前的属性（不能宣言与对象当前属性相同的属性），并将宣言的属性存入效果标签。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- 效果处理函数：取得对象怪兽，若对象仍与效果有联系且表侧表示，则赋予其“直到回合结束时变成宣言属性”的持续效果。
function c20127343.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
