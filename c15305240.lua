--鹵獲装置
-- 效果：
-- 双方选择自己场上怪兽各1只，那些怪兽的控制权交换。但是这张卡的控制者必须选择自己场上表侧表示存在的通常怪兽。
function c15305240.initial_effect(c)
	-- 双方选择自己场上怪兽各1只，那些怪兽的控制权交换。但是这张卡的控制者必须选择自己场上表侧表示存在的通常怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15305240.target)
	e1:SetOperation(c15305240.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡片的函数：选择自己场上表侧表示、通常怪兽、能够改变控制权，并且该怪兽离开后其控制者场上仍有可用的怪兽区，以容纳交换来的怪兽。
function c15305240.filter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsAbleToChangeControler()
		-- 确认该怪兽的控制者在怪兽离开后仍有空余的怪兽区可用，防止控制权交换后没有区域放置对方怪兽。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 发动判定：自己场上存在满足条件的通常怪兽，且对方场上有能改变控制权的怪兽，满足任意条件则不能发动。
function c15305240.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只符合条件的通常怪兽（表侧表示、通常怪兽、能改变控制权且有空位）。
	if chk==0 then return Duel.IsExistingMatchingCard(c15305240.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可改变控制权的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置本次效果处理类别为改变控制权，由于对象在处理时由双方各选，因此不预先指定目标卡。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
-- 效果处理时先再次确认双方场上仍存在满足条件的怪兽，若任意一方不满足则直接终止处理，避免无效交换。
function c15305240.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认自己场上仍存在符合条件的通常怪兽，否则不处理。
	if not Duel.IsExistingMatchingCard(c15305240.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果处理时确认对方场上仍存在可改变控制权的怪兽，否则不处理。
		or not Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
	then return end
	-- 向发动者显示选择提示，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 发动者从自己场上选择1只符合filter条件的怪兽，返回选中的卡组g1。
	local g1=Duel.SelectMatchingCard(tp,c15305240.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 为发动者选中的怪兽显示选中动画，并记录该怪兽被选为对象。
	Duel.HintSelection(g1)
	-- 向对方玩家显示选择提示，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 对方玩家从自己场上选择1只可改变控制权的怪兽，返回选中的卡组g2。
	local g2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToChangeControler,1-tp,LOCATION_MZONE,0,1,1,nil)
	-- 为对方选中的怪兽显示选中动画，并记录该怪兽被选为对象。
	Duel.HintSelection(g2)
	local c1=g1:GetFirst()
	local c2=g2:GetFirst()
	-- 交换两只怪兽的控制权，以此实现“那些怪兽的控制权交换”的效果。
	Duel.SwapControl(c1,c2,0,0)
end
