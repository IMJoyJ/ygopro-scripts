--ダーク・ジェノサイド・カッター
-- 效果：
-- 自己场上有暗属性怪兽3只以上存在的场合才能发动。选择场上表侧表示存在的1张卡从游戏中除外。
function c41722932.initial_effect(c)
	-- 创建效果，设置为发动时点，取对象，除外效果，条件为己方场上存在3只以上暗属性怪兽，目标为场上表侧表示存在的1张卡，发动时除外该卡
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
-- 过滤函数，检查是否为表侧表示且属性为暗的怪兽
function c41722932.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果发动条件，检查己方场上是否存在3只以上表侧表示的暗属性怪兽
function c41722932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在3只以上满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c41722932.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 过滤函数，检查是否为表侧表示且可以被除外的卡
function c41722932.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 设置效果目标，检查己方场上是否存在满足filter条件的卡，提示选择除外的卡并选择目标
function c41722932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c41722932.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足选择目标的条件，即场上存在满足filter条件的卡
	if chk==0 then return Duel.IsExistingTarget(c41722932.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上满足filter条件的1张卡作为目标
	local g=Duel.SelectTarget(tp,c41722932.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息，确定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果发动时的处理函数，将目标卡除外
function c41722932.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示的形式除外，原因来自效果
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
