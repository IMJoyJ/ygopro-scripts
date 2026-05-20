--ロスト・ネクスト
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽。从自己卡组选1张和选择的卡同名的卡送去墓地。
function c7076131.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽。从自己卡组选1张和选择的卡同名的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c7076131.target)
	e1:SetOperation(c7076131.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否与指定卡名相同且能送去墓地
function c7076131.filter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end
-- 过滤函数：检查怪兽是否表侧表示，且卡组中存在可送去墓地的同名卡
function c7076131.tgfilter(c,tp)
	-- 检查怪兽是否表侧表示，且自己卡组中是否存在至少1张同名卡可以送去墓地
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c7076131.filter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 效果发动时的目标选择与合法性检查
function c7076131.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7076131.tgfilter(chkc,tp) end
	-- 检查自己场上是否存在满足条件的表侧表示怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c7076131.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c7076131.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理的执行函数
function c7076131.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给玩家发送提示信息：请选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从自己卡组中选择1张与对象怪兽同名的卡
		local g=Duel.SelectMatchingCard(tp,c7076131.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
