--マジックアブソーバー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：这张卡的等级上升这张卡的魔力指示物数量的数值。
-- ③：把这张卡3个魔力指示物取除，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c43930492.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 创建效果e0，设置其类型为持续/场上效果，不可被无效化，触发条件为连锁发动时，操作为aux.chainreg。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 创建效果e1，设置其类型为持续/场上效果，触发条件为连锁处理结束时，操作为c43930492.acop。
-- 相关子函数：
-- c43930492.acop: 如果连锁发动了魔法卡且这张卡在场上存在，则给这张卡添加1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c43930492.acop)
	c:RegisterEffect(e1)
	-- 创建效果e2，设置其类型为单次效果，只对自己有效，作用范围为怪兽区域，代码为改变等级，值为c43930492.lvval。
-- 相关子函数：
-- c43930492.lvval: 返回这张卡上的魔力指示物数量。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(c43930492.lvval)
	c:RegisterEffect(e2)
	-- 创建效果e3，设置描述文本、类型为起动效果，类别为盖放魔法/陷阱，可以指定对象，作用范围为怪兽区域，限制1回合只能使用一次，设置发动代价为c43930492.setcost，指定目标卡为c43930492.settg，操作为c43930492.setop。
-- 相关子函数：
-- c43930492.setcost: 如果可以移除3个魔力指示物则返回true，否则返回false；移除3个魔力指示物。
-- c43930492.settg: 检查目标卡是否为自己控制的墓地速攻魔法且可盖放；如果满足条件则返回true，否则返回false；检查是否有符合条件的卡片存在于墓地；提示玩家选择要盖放的卡片；选择目标卡；设置操作信息。
-- c43930492.setop: 获取当前连锁的目标卡；如果目标卡与效果相关，则将其盖放在自己的魔法陷阱区域。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43930492,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_SSET)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,43930492)
	e3:SetCost(c43930492.setcost)
	e3:SetTarget(c43930492.settg)
	e3:SetOperation(c43930492.setop)
	c:RegisterEffect(e3)
end
c43930492.mentioned_counter={
	[0x1]=true,
}
-- 如果连锁发动了魔法卡且这张卡在场上存在，则给这张卡添加1个魔力指示物。
function c43930492.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 返回这张卡上的魔力指示物数量。
function c43930492.lvval(e,c)
	return c:GetCounter(0x1)
end
-- 检查是否可以移除3个魔力指示物作为代价；移除3个魔力指示物。
function c43930492.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 判断目标卡是否为速攻魔法且可盖放。
function c43930492.setfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 检查目标卡是否为自己控制的墓地速攻魔法且可盖放；如果满足条件则返回true，否则返回false；检查是否有符合条件的卡片存在于墓地；提示玩家选择要盖放的卡片；选择目标卡；设置操作信息。
function c43930492.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43930492.setfilter(chkc) end
	-- 检查是否有符合条件的卡片存在于墓地。
	if chk==0 then return Duel.IsExistingTarget(c43930492.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标卡。
	local g=Duel.SelectTarget(tp,c43930492.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将选定的卡从墓地移至魔法陷阱区域。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 获取当前连锁的目标卡；如果目标卡与效果相关，则将其盖放在自己的魔法陷阱区域。
function c43930492.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡盖放在自己的魔法陷阱区域。
		Duel.SSet(tp,tc)
	end
end
