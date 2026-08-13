--シールドクラッシュ
-- 效果：
-- ①：以场上1只守备表示怪兽为对象才能发动。那只守备表示怪兽破坏。
function c30683373.initial_effect(c)
	-- ①：以场上1只守备表示怪兽为对象才能发动。那只守备表示怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30683373.target)
	e1:SetOperation(c30683373.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为守备表示，用于筛选符合条件的对象。
function c30683373.filter(c)
	return c:IsDefensePos()
end
-- 发动时的目标选择处理：先验证已选对象是否合法；再确认场上存在符合条件的守备表示怪兽；然后提示玩家选择1只守备表示怪兽作为对象，并设置破坏的操作信息。
function c30683373.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30683373.filter(chkc) end
	-- 在发动合法性检查阶段，确认场上是否存在至少1只守备表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c30683373.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只守备表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30683373.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本次效果将破坏1张卡（所选对象），供连锁判定与效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：获取对象卡，确认其仍与效果相关且仍为守备表示后将其破坏。
function c30683373.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsDefensePos() then
		-- 以效果原因将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
