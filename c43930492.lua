--マジックアブソーバー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：这张卡的等级上升这张卡的魔力指示物数量的数值。
-- ③：把这张卡3个魔力指示物取除，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c43930492.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ②：这张卡的等级上升这张卡的魔力指示物数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c43930492.acop)
	c:RegisterEffect(e1)
	-- ③：把这张卡3个魔力指示物取除，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(c43930492.lvval)
	c:RegisterEffect(e2)
	-- 效果作用
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
-- 当有魔法卡发动并处理完毕时，若该效果为发动类型且为魔法卡，则给自身放置1个魔力指示物
function c43930492.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 使此卡的等级上升其魔力指示物数量
function c43930492.lvval(e,c)
	return c:GetCounter(0x1)
end
-- 支付3个魔力指示物作为cost
function c43930492.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 速攻魔法卡的过滤条件
function c43930492.setfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 选择墓地一张速攻魔法卡作为对象
function c43930492.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43930492.setfilter(chkc) end
	-- 确认场上是否存在满足条件的墓地速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(c43930492.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的墓地速攻魔法卡
	local g=Duel.SelectTarget(tp,c43930492.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表明将要从墓地离开的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 将选中的卡在自己的魔法与陷阱区域盖放
function c43930492.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,tc)
	end
end
