--ジャンク・チェンジャー
-- 效果：
-- 「废品变更者」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，可以以场上1只「废品」怪兽为对象从以下效果选择1个发动。
-- ●作为对象的怪兽的等级上升1星。
-- ●作为对象的怪兽的等级下降1星。
function c1006081.initial_effect(c)
	-- 创建效果，设置描述为“等级变更”，类型为单次触发效果，在召唤成功时发动，目标一张卡片并延迟生效，限制一回合只能使用一次，设置目标选择函数和操作函数，并将效果注册到卡片上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1006081,0))  --"等级变更"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,1006081)
	e1:SetTarget(c1006081.target)
	e1:SetOperation(c1006081.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于筛选场上表侧表示、等级大于0且属于“废品”系列的怪兽。
function c1006081.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x43)
end
-- 定义目标选择函数，首先检查是否是确认阶段，如果是则返回目标卡片是否在怪兽区并且符合过滤条件；如果不是确认阶段，则检查是否存在满足过滤条件的卡片作为目标。然后提示玩家选择表侧表示的卡片，使用Duel.SelectTarget选择目标卡片，并提示玩家选择要发动的效果（等级上升或下降），将选择的结果存储在效果标签中。
function c1006081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1006081.filter(chkc) end
	-- 检查是否有可用的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c1006081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求其选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 使用Duel.SelectTarget函数从满足过滤条件的卡片中选择一张作为目标。
	local g=Duel.SelectTarget(tp,c1006081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local op=0
	-- 向玩家发送提示信息，要求其选择要发动的效果。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	if g:GetFirst():IsLevel(1) then
		-- 如果选中的怪兽等级为1，则提供“等级上升1星”的选项。
		op=Duel.SelectOption(tp,aux.Stringid(1006081,1))  --"等级上升1星"
	else
		-- 否则，提供“等级上升1星/等级下降1星”两个选项。
		op=Duel.SelectOption(tp,aux.Stringid(1006081,1),aux.Stringid(1006081,2))  --"等级上升1星/等级下降1星"
	end
	e:SetLabel(op)
end
-- 定义操作函数，获取效果发动者和目标卡片。如果目标卡片是表侧表示且与该效果相关联，则创建一个新的效果，设置其属性为不可无效、单次生效、改变等级，并设置为在事件发生后重置。根据效果标签的值（0或1）设置等级变化的数值（+1或-1），并将该效果注册到目标卡片上。
function c1006081.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建改变等级的效果，设置为不可无效、单次生效，代码为EFFECT_UPDATE_LEVEL，重置条件为RESET_EVENT+RESETS_STANDARD。如果效果标签为0，则将等级变化值设为1（上升）；否则，设为-1（下降）。最后，将该效果注册到目标卡片上。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		tc:RegisterEffect(e1)
	end
end
