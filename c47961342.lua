--転轍地点
-- 效果：
-- ①：对方场上有怪兽3只以上存在的场合，选那之内的1只。对方必须把以下其中任意种送去墓地。
-- ●选的怪兽
-- ●选的怪兽以外的自身场上的全部怪兽
local s,id,o=GetID()
-- 创建并注册卡牌效果，设置为魔陷发动、自由连锁时点，包含目标选择和处理函数
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断对方场上有3只以上怪兽存在，否则不满足发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上怪兽数量是否大于等于3
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>2 end
	-- 设置连锁操作信息为将对方场上1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
-- 处理函数开始，再次确认对方场上有3只以上怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 当对方场上怪兽不足3只时直接返回不发动
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<3 then return end
	-- 向玩家提示选择对方场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上的1只怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 显示所选怪兽被选为对象的动画效果
	Duel.HintSelection(g)
	-- 向对方提示选择将怪兽送去墓地的方式
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让对方选择将选中怪兽送去墓地或将其余怪兽全部送去墓地
	local opt=Duel.SelectOption(1-tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"把选的1只怪兽送去墓地/把其他全部怪兽送去墓地"
	if opt==0 then
		-- 将选中的怪兽送去对方墓地
		Duel.SendtoGrave(g,REASON_RULE,1-tp)
	else
		-- 获取除已选怪兽外的对方场上的所有怪兽
		local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,g)
		-- 将除选中怪兽外的其他怪兽全部送去对方墓地
		Duel.SendtoGrave(g2,REASON_RULE,1-tp)
	end
end
