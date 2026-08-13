--即神仏
-- 效果：
-- 选择自己场上存在的1只怪兽送去墓地。
function c15103313.initial_effect(c)
	-- 选择自己场上存在的1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15103313.target)
	e1:SetOperation(c15103313.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的取对象处理：若为连锁处理则先验证对象是否合法；否则检查自己场上是否存在可选怪兽，若满足则提示玩家选择1只怪兽作为对象，并登记将其送去墓地的操作信息。
function c15103313.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 发动条件判定：检查自己场上是否存在至少1只可以作为对象的怪兽，若存在则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送‘请选择要送去墓地的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只怪兽作为效果对象，并自动登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息，声明此效果会将1只对象怪兽送去墓地，供其他效果进行联动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理时，确认对象怪兽仍与效果关联且控制者仍为自己，然后将其送去墓地。
function c15103313.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 将对象怪兽以效果原因从场上送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
