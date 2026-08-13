--緊急儀式術
-- 效果：
-- ①：自己场上没有仪式怪兽存在的场合，从自己的手卡·墓地把1张仪式魔法卡除外才能发动。这张卡的效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
function c38844957.initial_effect(c)
	-- ①：自己场上没有仪式怪兽存在的场合，从自己的手卡·墓地把1张仪式魔法卡除外才能发动。这张卡的效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c38844957.condition)
	e1:SetCost(c38844957.cost)
	e1:SetTarget(c38844957.target)
	e1:SetOperation(c38844957.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否表侧表示且为仪式怪兽（类型二进制与0x81等于0x81）。
function c38844957.cfilter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x81)==0x81
end
-- 发动条件判定：检查自己场上是否存在满足cfilter（表侧仪式怪兽）的卡，若不存在则条件成立。
function c38844957.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 通过Duel.IsExistingMatchingCard检查我方怪兽区域是否存在表侧仪式怪兽，若不存在则返回true，即满足“自己场上没有仪式怪兽存在的场合”。
	return not Duel.IsExistingMatchingCard(c38844957.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 选择素材过滤：从手卡·墓地中筛选出符合以下条件的仪式魔法卡：类型为仪式魔法、可作为代价除外，并且拥有可发动的效果（通过CheckActivateEffect获取其发动效果，若存在则非nil）。
function c38844957.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- 代价函数：先将e的Label标记设为1，表示代价相关的前置标记已完成，随后返回true，实际除外仪式魔法卡的操作放在target阶段执行。
function c38844957.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 发动时的目标处理：先确认存在可用素材；选择手卡·墓地中的1张仪式魔法卡；获取该卡发动效果信息存入LabelObject；将选择的卡表侧除外作为代价；将该效果属性复制给本卡；调用被复制效果的目标函数完成对象选择与发动准备；最后清除操作信息，避免复制来的效果信息干扰响应判定。
function c38844957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手卡·墓地是否存在1张以上满足filter条件的仪式魔法卡，用于判定该效果能否发动。
		return Duel.IsExistingMatchingCard(c38844957.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	-- 向玩家展示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡·墓地选择1张满足filter条件的仪式魔法卡作为要除外的对象。
	local g=Duel.SelectMatchingCard(tp,c38844957.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选择的仪式魔法卡以表侧表示除外，作为发动本卡的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息，使这张卡复制仪式魔法卡发动效果的过程不会被其他卡错误地响应或当作关联信息处理。
	Duel.ClearOperationInfo(0)
end
-- 效果处理：取出被存储在LabelObject中的仪式魔法卡发动效果，若存在，则执行其对应的效果处理函数，从而将本卡的效果变成与该仪式魔法卡发动时的仪式召唤效果相同。
function c38844957.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
