--太陽の書
-- 效果：
-- ①：以场上1只里侧表示怪兽为对象才能发动。那只里侧表示怪兽变成表侧攻击表示。
function c38699854.initial_effect(c)
	-- ①：以场上1只里侧表示怪兽为对象才能发动。那只里侧表示怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38699854.target)
	e1:SetOperation(c38699854.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择处理：确认对象必须是场上里侧表示怪兽，并选择1只作为效果对象，同时设置改变表示形式的操作信息。
function c38699854.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	-- 发动合法性检查：在发动时点检查场上是否存在至少1只里侧表示怪兽可作为对象，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择里侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让玩家从双方主要怪兽区选择1只里侧表示怪兽，并将其设为该效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本次效果处理将改变对象卡的表示形式（位置变更）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数：取得对象卡，若对象仍与效果相关且为里侧表示，则将其变为表侧攻击表示。
function c38699854.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中该效果所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 将对象卡的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
