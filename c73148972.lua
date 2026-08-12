--無情の抹殺
-- 效果：
-- 选择自己场上存在的1只怪兽发动。选择的自己怪兽送去墓地，对方手卡随机1张送去墓地。
function c73148972.initial_effect(c)
	-- 选择自己场上存在的1只怪兽发动。选择的自己怪兽送去墓地，对方手卡随机1张送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73148972.target)
	e1:SetOperation(c73148972.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与准备阶段，验证并选择自己场上的1只怪兽作为对象，并注册送去墓地的操作信息
function c73148972.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 在发动准备阶段，检查自己场上是否存在至少1只可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家发送提示信息，要求选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只怪兽作为该效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，声明此效果包含将选中的1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理阶段，尝试将作为对象的怪兽送去墓地，若成功则随机将对方1张手牌送去墓地
function c73148972.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp)
		-- 将该怪兽因效果送去墓地，并确认其是否已成功存在于墓地
		and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取对方的所有手牌，并从中随机选择1张
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
		-- 将随机选中的对方手牌因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
