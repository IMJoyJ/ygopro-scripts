--『攻撃』封じ
-- 效果：
-- 指定的对方场上的1只表侧表示的怪兽转为守备表示。
function c25880422.initial_effect(c)
	-- 指定的对方场上的1只表侧表示的怪兽转为守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c25880422.target)
	e1:SetOperation(c25880422.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择对方场上表侧攻击表示且可以变更表示形式的怪兽。
function c25880422.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 发动时的目标选取处理：检查是否有符合条件的对象，并让玩家选择1只对方场上的表侧攻击表示且可变更表示形式的怪兽作为效果对象。
function c25880422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25880422.filter(chkc) end
	-- 若为发动条件检查，判定对方场上是否存在至少1只满足过滤条件的表侧攻击表示且可变更表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c25880422.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择提示消息，提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方主要怪兽区选择1只满足过滤条件的怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c25880422.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理包含改变表示形式，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：获取效果对象，若对象仍与效果关联且仍为表侧攻击表示，则将其变为表侧守备表示。
function c25880422.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中第一个效果对象，即之前选择的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 将该怪兽的表示形式变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
