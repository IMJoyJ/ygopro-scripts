--鹵獲装置
-- 效果：
-- 双方选择自己场上怪兽各1只，那些怪兽的控制权交换。但是这张卡的控制者必须选择自己场上表侧表示存在的通常怪兽。
function c15305240.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点，可以自由连锁，目标函数为c15305240.target，发动函数为c15305240.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15305240.target)
	e1:SetOperation(c15305240.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：表侧表示、通常怪兽、可以改变控制权、且该怪兽控制者场上存在可用怪兽区
function c15305240.filter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAbleToChangeControler()
		-- 检查该怪兽控制者场上是否存在可用怪兽区，确保可以交换控制权
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 目标函数，检查双方场上是否存在可交换控制权的怪兽
function c15305240.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c15305240.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可交换控制权的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，表示此效果属于改变控制权类别
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
-- 发动函数，再次确认双方场上是否存在满足条件的怪兽
function c15305240.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的怪兽
	if not Duel.IsExistingMatchingCard(c15305240.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可交换控制权的怪兽
		or not Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
	then return end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上满足条件的怪兽作为目标
	local g1=Duel.SelectMatchingCard(tp,c15305240.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示所选怪兽被选为对象的动画效果
	Duel.HintSelection(g1)
	-- 提示对方玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上可交换控制权的怪兽作为目标
	local g2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToChangeControler,1-tp,LOCATION_MZONE,0,1,1,nil)
	-- 显示所选怪兽被选为对象的动画效果
	Duel.HintSelection(g2)
	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	-- 交换两个目标怪兽的控制权
	Duel.SwapControl(c1,c2,0,0)
end
