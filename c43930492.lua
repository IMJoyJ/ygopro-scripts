--マジックアブソーバー
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：这张卡的等级上升这张卡的魔力指示物数量的数值。
-- ③：把这张卡3个魔力指示物取除，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c43930492.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 效果①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置效果操作为aux.chainreg，用于记录连锁发生时这张卡在场上存在（作为效果①触发的前提条件）
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 效果①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c43930492.acop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡的等级上升这张卡的魔力指示物数量的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(c43930492.lvval)
	c:RegisterEffect(e2)
	-- 效果③：把这张卡3个魔力指示物取除，以自己墓地1张速攻魔法卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
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
-- 当连锁处理结束时，如果是魔法卡的发动效果且这张卡在连锁发生时已在场上，则给这张卡放置1个魔力指示物
function c43930492.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 返回这张卡的魔力指示物数量，作为等级上升的数值
function c43930492.lvval(e,c)
	return c:GetCounter(0x1)
end
-- 检查是否可以取除3个魔力指示物作为代价，如果可以则取除3个魔力指示物
function c43930492.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 筛选墓地的速攻魔法卡中可以被盖放的卡
function c43930492.setfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
end
-- 选择墓地的速攻魔法卡为对象，设置操作信息
function c43930492.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c43930492.setfilter(chkc) end
	-- 检查自己墓地是否存在可以作为对象的速攻魔法卡
	if chk==0 then return Duel.IsExistingTarget(c43930492.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息"请选择要盖放的卡"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从墓地选择1张速攻魔法卡作为效果的对象
	local g=Duel.SelectTarget(tp,c43930492.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示要从墓地盖放1张卡（涉及墓地的效果）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 将选择的速攻魔法卡盖放到自己的魔法与陷阱区域
function c43930492.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡（即选择的墓地速攻魔法卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡盖放到自己的魔法与陷阱区域
		Duel.SSet(tp,tc)
	end
end
