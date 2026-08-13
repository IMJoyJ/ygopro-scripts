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
-- 过滤函数：筛选出表侧表示且可以改变表示形式的怪兽。
function c50122883.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 发动时的目标处理：检查是否取对象、是否满足发动条件，提示玩家选择1只表侧表示且可改变表示形式的怪兽作为对象，并设置操作信息。
function c50122883.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50122883.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家显示选择提示，提示内容为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方怪兽区域选择1只表侧表示且可改变表示形式的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c50122883.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息，类别为改变表示形式，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时的操作：取得仍与效果关联且表侧表示的对象怪兽，改变其表示形式。
function c50122883.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽的表示形式在表侧攻击表示和表侧守备表示之间互换（表侧攻击改为表侧守备，表侧守备改为表侧攻击）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
