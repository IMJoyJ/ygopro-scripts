--緊急儀式術
-- 效果：
-- ①：自己场上没有仪式怪兽存在的场合，从自己的手卡·墓地把1张仪式魔法卡除外才能发动。这张卡的效果变成和那张仪式魔法卡发动时的仪式召唤效果相同。
function c38844957.initial_effect(c)
	-- 创建效果，设置为自由时点发动，条件为己方场上没有仪式怪兽存在，代价为除外一张仪式魔法卡，目标为选择仪式魔法卡，效果为复制该仪式魔法卡的仪式召唤效果
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
-- 过滤函数，用于判断己方场上是否存在表侧表示的仪式怪兽
function c38844957.cfilter(c)
	return c:IsFaceup() and bit.band(c:GetType(),0x81)==0x81
end
-- 效果发动条件，判断己方场上是否没有仪式怪兽存在
function c38844957.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 己方场上没有仪式怪兽存在
	return not Duel.IsExistingMatchingCard(c38844957.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断手卡或墓地是否存在可作为除外代价的仪式魔法卡
function c38844957.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果发动代价函数，设置标签为1表示已支付代价
function c38844957.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动目标函数，选择一张仪式魔法卡并复制其效果
function c38844957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手卡或墓地是否存在满足条件的仪式魔法卡
		return Duel.IsExistingMatchingCard(c38844957.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的仪式魔法卡
	local g=Duel.SelectMatchingCard(tp,c38844957.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选中的仪式魔法卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁中的操作信息
	Duel.ClearOperationInfo(0)
end
-- 效果发动执行函数，执行复制的仪式召唤效果
function c38844957.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
