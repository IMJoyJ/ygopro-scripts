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
-- 效果发动条件的判定函数：在发动时若chk==0则返回true表示可以发动，并预先设置操作信息。
function c13532663.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，声明本效果涉及改变控制权；由于具体对象在效果处理时由对方选择，故对象参数为nil，数量为0。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,0,0,0)
end
-- 定义可被选择的对方怪兽的筛选条件：该怪兽能够改变控制权，且其控制者在它离开后仍有可用的怪兽区（用于容纳此卡）。
function c13532663.filter(c)
	local tp=c:GetControler()
	-- 筛选条件为：对象怪兽可以改变控制权，并且其控制者的怪兽区在对象离开后仍有一个空位（用于此卡转移过去）。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果处理函数：先获取此卡，然后依次检查此卡是否因战斗破坏已确定、是否仍与效果关联、自身能否改变控制权、控制者怪兽区是否有空位、对方场上是否存在可选对象，任何一项不满足则直接终止处理。
function c13532663.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not c:IsRelateToEffect(e)
		-- 检查此卡自身能改变控制权，且其当前控制者tp的怪兽区在它离开后仍有空位，用于容纳对方选择交换过来的怪兽。
		or not c:IsAbleToChangeControler() or Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)<=0
		-- 检查对方（1-tp）场上是否存在至少1只满足filter条件的怪兽，若不存在则无法继续处理。
		or not Duel.IsExistingMatchingCard(c13532663.filter,tp,0,LOCATION_MZONE,1,nil) then
		return
	end
	-- 向对方玩家（1-tp）发送选择提示，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 由对方玩家（1-tp）从自己场上选择1只满足filter条件的怪兽作为交换控制权的对象。
	local g=Duel.SelectMatchingCard(1-tp,c13532663.filter,1-tp,LOCATION_MZONE,0,1,1,nil)
	-- 将此卡与对方选择的怪兽交换控制权（第三个、第四个参数为0表示不额外设置复位阶段/计数）。
	Duel.SwapControl(c,g:GetFirst(),0,0)
end
