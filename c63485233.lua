--スター・チェンジャー
-- 效果：
-- 选择场上表侧表示存在的1只怪兽，从以下效果选择1个发动。
-- ●那只怪兽的等级上升1星。
-- ●那只怪兽的等级下降1星。
function c63485233.initial_effect(c)
	-- 选择场上表侧表示存在的1只怪兽，从以下效果选择1个发动。●那只怪兽的等级上升1星。●那只怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63485233.target)
	e1:SetOperation(c63485233.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且等级在1星以上的怪兽
function c63485233.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 效果发动的靶向选择与分支效果宣言处理
function c63485233.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63485233.filter(chkc) end
	-- 检查场上是否存在至少1只符合条件的表侧表示怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c63485233.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示且等级在1星以上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63485233.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local op=0
	-- 若对象怪兽等级为1星，则只能选择“等级上升1星”的选项
	if tc:IsLevel(1) then op=Duel.SelectOption(tp,aux.Stringid(63485233,0))  --"等级上升1星"
	-- 若对象怪兽等级在2星以上，则可选择“等级上升1星”或“等级下降1星”的选项
	else op=Duel.SelectOption(tp,aux.Stringid(63485233,0),aux.Stringid(63485233,1)) end  --"等级上升1星/等级下降1星"
	e:SetLabel(op)
end
-- 效果处理，根据玩家的选择改变目标怪兽的等级
function c63485233.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- ●那只怪兽的等级上升1星。●那只怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else e1:SetValue(-1) end
		tc:RegisterEffect(e1)
	end
end
