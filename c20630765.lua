--魔石術師 クルード
-- 效果：
-- 1回合1次，每次这张卡以外的怪兽的效果发动，给这张卡放置1个魔石指示物（最多1个）。这张卡放置的魔石指示物每有1个，这张卡的守备力上升300。此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外。
function c20630765.initial_effect(c)
	c:EnableCounterPermit(0x16)
	c:SetCounterLimit(0x16,1)
	-- 创建效果，设置类型为连续/场上效果，不可无效化，触发时机为连锁发动，作用范围为主怪兽区，操作为aux.chainreg函数。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 创建效果，设置类型为连续/场上效果，触发条件为连锁处理结束，作用范围为主怪兽区，限制次数为1次，操作为c20630765.ctop函数。
-- 相关子函数：
-- c20630765.ctop: 如果对方怪兽的效果发动且不是这张卡，则给这张卡添加一个魔石指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c20630765.ctop)
	c:RegisterEffect(e1)
	-- 创建效果，设置类型为单次效果，只对自己有效，作用范围为主怪兽区，触发条件为更新守备力，数值由c20630765.defup函数计算。
-- 相关子函数：
-- c20630765.defup: 返回魔石指示物数量乘以300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c20630765.defup)
	c:RegisterEffect(e2)
	-- 创建效果，设置描述为“除外”，类别为移除效果，类型为起动效果，作用范围为主怪兽区，允许取对象，限制次数为1次，费用为c20630765.rmcost函数，目标选择为c20630765.rmtg函数，操作为c20630765.rmop函数。
-- 相关子函数：
-- c20630765.rmcost: 检查是否可以移除魔石指示物作为费用，如果可以则移除。
-- c20630765.rmtg: 确定目标卡片为对方墓地的可除外卡片，并提示玩家选择。
-- c20630765.rmop: 从游戏中移除选定的目标卡片。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20630765,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c20630765.rmcost)
	e3:SetTarget(c20630765.rmtg)
	e3:SetOperation(c20630765.rmop)
	c:RegisterEffect(e3)
end
c20630765.mentioned_counter={
	[0x16]=true,
}
-- 如果对方怪兽的效果发动且不是这张卡，则给这张卡添加一个魔石指示物。
function c20630765.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and c~=e:GetHandler() and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
-- 返回魔石指示物数量乘以300。
function c20630765.defup(e,c)
	return c:GetCounter(0x16)*300
end
-- 检查是否可以移除魔石指示物作为费用，如果可以则移除。
function c20630765.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除魔石指示物作为费用。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x16,1,REASON_COST) end
	-- 移除魔石指示物作为费用。
	Duel.RemoveCounter(tp,1,0,0x16,1,REASON_COST)
end
-- 确定目标卡片为对方墓地的可除外卡片，并提示玩家选择。
function c20630765.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否存在符合条件的墓地卡片。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示信息“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择一张可移除的卡片。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置当前处理的连锁的操作信息，表示为移除效果，目标为选定的卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 从游戏中移除选定的目标卡片。
function c20630765.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片从游戏中移除。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
