--ダミー・ゴーレム
-- 效果：
-- 反转：对方选择所控制的1只怪兽。选择怪兽和这张卡的控制权交换。
function c13532663.initial_effect(c)
	-- 反转：对方选择所控制的1只怪兽。选择怪兽和这张卡的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13532663,0))  --"控制权交换"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c13532663.target)
	e1:SetOperation(c13532663.operation)
	c:RegisterEffect(e1)
end
-- 设置效果目标函数
function c13532663.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为控制权改变效果
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
-- 定义过滤函数，用于筛选可交换控制权的怪兽
function c13532663.filter(c)
	local tp=c:GetControler()
	-- 过滤条件：怪兽可以改变控制权且目标玩家怪兽区有空位
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 设置效果发动函数
function c13532663.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not c:IsRelateToEffect(e)
		-- 判断自身是否可以改变控制权且场上存在可用怪兽区
		or not c:IsAbleToChangeControler() or Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)<=0
		-- 判断对方场上是否存在可选择的怪兽
		or not Duel.IsExistingMatchingCard(c13532663.filter,tp,0,LOCATION_MZONE,1,nil) then
		return
	end
	-- 向对方玩家提示选择怪兽的提示消息
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)
	-- 让对方选择1只怪兽作为控制权交换对象
	local g=Duel.SelectMatchingCard(1-tp,c13532663.filter,1-tp,LOCATION_MZONE,0,1,1,nil)
	-- 交换自身与目标怪兽的控制权
	Duel.SwapControl(c,g:GetFirst(),0,0)
end
