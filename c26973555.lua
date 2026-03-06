--FNo.0 未来龍皇ホープ
-- 效果：
-- 「No.」怪兽以外的相同阶级的超量怪兽×3
-- 规则上，这张卡的阶级当作1阶使用，这个卡名也当作「未来皇 霍普」卡使用。这张卡也能在自己场上的「未来No.0 未来皇 霍普」上面重叠来超量召唤。
-- ①：这张卡不会被战斗·效果破坏。
-- ②：1回合1次，对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。这个效果把场上的怪兽的效果的发动无效的场合，再得到那个控制权。
function c26973555.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c26973555.mfilter,c26973555.xyzcheck,3,3,c26973555.ovfilter,aux.Stringid(26973555,0))  --"是否在「未来No.0 未来皇 霍普」上面重叠来超量召唤？"
	-- ①：这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。这个效果把场上的怪兽的效果的发动无效的场合，再得到那个控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26973555,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c26973555.discon)
	e3:SetCost(c26973555.discost)
	e3:SetTarget(c26973555.distg)
	e3:SetOperation(c26973555.disop)
	c:RegisterEffect(e3)
end
-- 设置该卡的超量阶级为0
aux.xyz_number[26973555]=0
-- 判断叠放的怪兽是否为超量怪兽且不属于No.系列
function c26973555.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and not c:IsSetCard(0x48)
end
-- 判断叠放的怪兽数组是否为相同阶级
function c26973555.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 判断场上的重叠怪兽是否为未来No.0 未来皇 霍普
function c26973555.ovfilter(c)
	return c:IsFaceup() and c:IsCode(65305468)
end
-- 判断是否为对方怪兽效果的发动且该连锁可被无效
function c26973555.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 支付1个超量素材作为代价
function c26973555.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置连锁处理时的操作信息，包括使发动无效和可能的控制权变更
function c26973555.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetCategory(CATEGORY_NEGATE)
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 判断连锁发动位置是否在怪兽区域且效果对象卡存在
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE and re:GetHandler():IsRelateToEffect(re)
		and not re:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_CONTROL)
		-- 设置变更控制权的操作信息
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
	end
end
-- 处理连锁无效及控制权变更效果
function c26973555.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功被无效
	if Duel.NegateActivation(ev) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		and re:GetHandler():IsRelateToEffect(re) and not re:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 使对方怪兽的控制权转移给使用者
		Duel.GetControl(re:GetHandler(),tp)
	end
end
