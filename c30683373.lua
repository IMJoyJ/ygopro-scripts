--シールドクラッシュ
-- 效果：
-- ①：以场上1只守备表示怪兽为对象才能发动。那只守备表示怪兽破坏。
function c30683373.initial_effect(c)
	-- 效果发动条件设置，包括破坏效果分类、发动类型、取对象属性、自由时点触发
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30683373.target)
	e1:SetOperation(c30683373.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断目标是否为守备表示
function c30683373.filter(c)
	return c:IsDefensePos()
end
-- 效果处理目标选择函数，用于选择场上一只守备表示怪兽作为对象
function c30683373.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30683373.filter(chkc) end
	-- 判断是否满足发动条件，检查场上是否存在一只守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c30683373.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一只守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c30683373.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，确定将要破坏的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理函数，对选定目标进行破坏
function c30683373.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsDefensePos() then
		-- 以效果原因将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
