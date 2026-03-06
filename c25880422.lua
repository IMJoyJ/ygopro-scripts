--『攻撃』封じ
-- 效果：
-- 指定的对方场上的1只表侧表示的怪兽转为守备表示。
function c25880422.initial_effect(c)
	-- 效果原文内容：指定的对方场上的1只表侧表示的怪兽转为守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25880422.target)
	e1:SetOperation(c25880422.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选位置为表侧攻击表示且可以改变表示形式的怪兽
function c25880422.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果作用：设置效果目标为对方场上的1只表侧攻击表示的怪兽
function c25880422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25880422.filter(chkc) end
	-- 效果作用：判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c25880422.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 效果作用：选择符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c25880422.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果作用：将选中的怪兽变为守备表示
function c25880422.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 效果作用：将目标怪兽改变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
