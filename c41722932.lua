--ダーク・ジェノサイド・カッター
-- 效果：
-- 自己场上有暗属性怪兽3只以上存在的场合才能发动。选择场上表侧表示存在的1张卡从游戏中除外。
function c41722932.initial_effect(c)
	-- 自己场上有暗属性怪兽3只以上存在的场合才能发动。选择场上表侧表示存在的1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c41722932.condition)
	e1:SetTarget(c41722932.target)
	e1:SetOperation(c41722932.activate)
	c:RegisterEffect(e1)
end
-- 辅助过滤函数：判断卡片是否为表侧表示且属性为暗属性。
function c41722932.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果发动条件判定：检查己方场上是否存在3只以上表侧暗属性怪兽。
function c41722932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 在己方主要怪兽区检索是否存在至少3只表侧暗属性怪兽，用于满足发动条件。
	return Duel.IsExistingMatchingCard(c41722932.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 取对象时的卡片过滤：卡片必须表侧表示且可以被除外。
function c41722932.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果的发动时点处理：确认取对象条件，选择场上1张非本卡的表侧可除外卡，并设置除外操作信息。
function c41722932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c41722932.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动合法性检查：确认双方场上存在至少1张满足条件的对象卡（除本卡外）。
	if chk==0 then return Duel.IsExistingTarget(c41722932.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标：从双方场上选择1张满足条件且非本卡的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c41722932.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息：将选中的对象卡标记为除外类别，数量为1，用于后续效果处理和相关卡片的发动判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果的结算处理：取得对象卡并确认其仍在场上且与效果关联后，将其除外。
function c41722932.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时关联的对象卡（即发动时选择的目标）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示从游戏中除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
