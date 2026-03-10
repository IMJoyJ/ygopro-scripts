--朱い靴
-- 效果：
-- 反转：选择表侧表示的1只怪兽改变表示形式。
function c50122883.initial_effect(c)
	-- 反转：选择表侧表示的1只怪兽改变表示形式。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50122883,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c50122883.target)
	e1:SetOperation(c50122883.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的怪兽（表侧表示且可以改变表示形式）
function c50122883.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 设置效果目标，选择符合条件的怪兽作为目标
function c50122883.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50122883.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要改变表示形式的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c50122883.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数，将目标怪兽改变表示形式
function c50122883.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽改变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
