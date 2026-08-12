--A・ジェネクス・チェンジャー
-- 效果：
-- ①：1回合1次，以场上1只表侧表示怪兽为对象，宣言1个属性才能发动。那只怪兽直到回合结束时变成宣言的属性。
function c20127343.initial_effect(c)
	-- 创建效果，设置为起动效果，可以指定对象，只能在主要怪兽区发动，一回合只能发动一次，效果目标为选择场上表侧表示怪兽，效果处理为c20127343.cosop
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
-- 效果处理函数，用于处理选择目标怪兽和宣言属性的逻辑
function c20127343.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足发动条件，即场上是否存在至少一只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家宣言一个属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性，不能宣言已选择怪兽当前的属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- 效果处理函数，用于将目标怪兽属性改变
function c20127343.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将改变属性的效果注册给目标怪兽，直到回合结束时生效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
