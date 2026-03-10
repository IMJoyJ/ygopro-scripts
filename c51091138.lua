--導爆線
-- 效果：
-- ①：以和这张卡相同纵列的1张卡为对象才能把盖放的这张卡发动。那张卡破坏。
function c51091138.initial_effect(c)
	-- 效果原文内容：①：以和这张卡相同纵列的1张卡为对象才能把盖放的这张卡发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c51091138.condition)
	e1:SetTarget(c51091138.target)
	e1:SetOperation(c51091138.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断发动时是否在魔陷区（盖放状态）
function c51091138.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_SZONE)
end
-- 效果作用：过滤函数，用于判断目标卡是否在同一纵列
function c51091138.filter(c,g)
	return g:IsContains(c)
end
-- 效果作用：设置发动时的选择目标，选择与导爆线同纵列的场上卡作为破坏对象
function c51091138.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return chkc:IsOnField() and c51091138.filter(chkc,cg) end
	-- 效果作用：检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c51091138.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,cg) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择符合条件的目标卡
	local g=Duel.SelectTarget(tp,c51091138.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,cg)
	-- 效果作用：设置操作信息，标记本次效果为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果原文内容：①：以和这张卡相同纵列的1张卡为对象才能把盖放的这张卡发动。那张卡破坏。
function c51091138.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
