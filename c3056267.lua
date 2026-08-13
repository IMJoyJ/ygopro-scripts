--王座の侵略者
-- 效果：
-- 反转：选择对方场上存在的1只怪兽，那只怪兽和这张卡的控制权交换。这个效果在战斗阶段不能发动。
function c3056267.initial_effect(c)
	-- 反转：选择对方场上存在的1只怪兽，那只怪兽和这张卡的控制权交换。这个效果在战斗阶段不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3056267,0))  --"交换控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCondition(c3056267.condition)
	e1:SetTarget(c3056267.target)
	e1:SetOperation(c3056267.operation)
	c:RegisterEffect(e1)
end
-- 定义交换对象过滤函数：对方怪兽必须能够改变控制权，且其控制者场上在该怪兽离开后仍有空闲的怪兽区域，用于承接王座侵略者。
function c3056267.swapfilter(c)
	local tp=c:GetControler()
	-- 判断该怪兽是否可以改变控制权，同时其控制者场上在其离开后是否仍有可用的怪兽区，以确保控制权交换能够成功。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 定义效果发动条件：当前阶段不能处于战斗阶段（即不能在战斗阶段发动此反转效果），返回当前阶段是否不属于战斗阶段。
function c3056267.condition(e)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 效果发动时的目标选择与合法性检查：当效果合法且满足条件时，提示选择对方场上1只符合条件的怪兽作为对象，并将王座侵略者加入对象组，设置操作信息为改变控制权。
function c3056267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 检查王座侵略者控制者的场上，在王座侵略者离开后是否有空余的怪兽区，以容纳对方怪兽。
	if Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>0
		-- 检查对方场上的怪兽区是否存在至少1只满足swapfilter条件的怪兽，可作为控制权交换的对象。
		and Duel.IsExistingTarget(c3056267.swapfilter,tp,0,LOCATION_MZONE,1,nil) then
		-- 向当前玩家显示选择提示：请选择要改变控制权的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让当前玩家从对方场上选择1只符合条件的怪兽，并将其登记为本次连锁的处理对象。
		local mon=Duel.SelectTarget(tp,c3056267.swapfilter,tp,0,LOCATION_MZONE,1,1,nil)
		mon:AddCard(e:GetHandler())
		-- 设置操作信息：本次效果处理涉及改变控制权，目标组为mon（包含对方怪兽和王座侵略者），数量为2，供其他卡效果参照。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,mon,2,0,0)
	end
end
-- 效果处理时的操作：若王座侵略者和所选对象仍与该效果相关联（未离场或未失效），则交换这两只怪兽的控制权。
function c3056267.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时所选定的第一张对象卡（对方场上被选择的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		-- 将王座侵略者与对方怪兽的控制权进行交换。
		Duel.SwapControl(c,tc)
	end
end
