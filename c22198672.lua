--キャッスル・リンク
-- 效果：
-- ①：1回合1次，自己主要阶段以场上1只连接怪兽为对象才能发动。那只怪兽的位置向那只怪兽所连接区的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
-- ②：1回合1次，自己主要阶段才能发动。选自己的主要怪兽区域2只连接怪兽或者对方的主要怪兽区域2只连接怪兽，那些位置交换。
function c22198672.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段以场上1只连接怪兽为对象才能发动。那只怪兽的位置向那只怪兽所连接区的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22198672,0))  --"移动位置"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c22198672.seqtg)
	e2:SetOperation(c22198672.seqop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。选自己的主要怪兽区域2只连接怪兽或者对方的主要怪兽区域2只连接怪兽，那些位置交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22198672,1))  --"交换位置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22198672.chtg)
	e3:SetOperation(c22198672.chop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否为连接怪兽且其连接区存在可用的主要怪兽区域空格。
function c22198672.filter(c)
	if not c:IsType(TYPE_LINK) then return false end
	local p=c:GetControler()
	local zone=c:GetLinkedZone()&0x1f
	-- 检查目标怪兽的连接区是否在主要怪兽区域存在可用空格。
	return Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
end
-- 设置效果目标选择函数，用于选择满足条件的连接怪兽作为目标。
function c22198672.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22198672.filter(chkc) end
	-- 判断是否存在满足条件的连接怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c22198672.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要移动位置的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(22198672,2))  --"请选择要移动位置的怪兽"
	-- 选择满足条件的连接怪兽作为目标。
	Duel.SelectTarget(tp,c22198672.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 设置效果发动后的处理函数，用于执行怪兽位置移动操作。
function c22198672.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local p=tc:GetControler()
	local zone=tc:GetLinkedZone(p)&0x1f
	-- 判断目标怪兽的连接区是否在主要怪兽区域存在可用空格。
	if Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 then
		local i=0
		if p~=tp then i=16 end
		-- 提示玩家选择要移动到的位置。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 选择满足条件的空格作为目标位置。
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~(zone<<i))
		local nseq=math.log(s,2)-i
		-- 将目标怪兽移动到指定位置。
		Duel.MoveSequence(tc,nseq)
	end
end
-- 过滤函数，用于判断目标怪兽是否为连接怪兽且其控制者场上有其他连接怪兽。
function c22198672.chfilter1(c)
	return c:IsType(TYPE_LINK) and c:GetSequence()<5
		-- 检查目标怪兽的控制者场地上是否存在其他连接怪兽。
		and Duel.IsExistingMatchingCard(c22198672.chfilter2,c:GetControler(),LOCATION_MZONE,0,1,c)
end
-- 过滤函数，用于判断目标怪兽是否为连接怪兽。
function c22198672.chfilter2(c)
	return c:IsType(TYPE_LINK) and c:GetSequence()<5
end
-- 设置效果目标选择函数，用于选择满足条件的连接怪兽作为目标。
function c22198672.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的连接怪兽作为目标。
	if chk==0 then return Duel.IsExistingMatchingCard(c22198672.chfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 设置效果发动后的处理函数，用于执行怪兽位置交换操作。
function c22198672.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的连接怪兽作为目标。
	local g1=Duel.SelectMatchingCard(tp,c22198672.chfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	-- 显示被选为对象的动画效果。
	Duel.HintSelection(g1)
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的连接怪兽作为目标。
	local g2=Duel.SelectMatchingCard(tp,c22198672.chfilter2,tc1:GetControler(),LOCATION_MZONE,0,1,1,tc1)
	-- 显示被选为对象的动画效果。
	Duel.HintSelection(g2)
	local tc2=g2:GetFirst()
	-- 交换两个目标怪兽的位置。
	Duel.SwapSequence(tc1,tc2)
end
