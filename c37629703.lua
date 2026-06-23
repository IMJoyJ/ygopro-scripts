--白銀の城の竜飾灯
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，丢弃1张手卡才能发动。从手卡·卡组选1张「拉比林斯迷宫」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡加入手卡。
function c37629703.initial_effect(c)
	-- ①：把手卡·场上的这张卡送去墓地，丢弃1张手卡才能发动。从手卡·卡组选1张「拉比林斯迷宫」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37629703,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,37629703)
	e1:SetCost(c37629703.stcost)
	e1:SetTarget(c37629703.sttg)
	e1:SetOperation(c37629703.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37629703,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,37629704)
	e2:SetCondition(c37629703.thcon)
	e2:SetTarget(c37629703.thtg)
	e2:SetOperation(c37629703.thop)
	c:RegisterEffect(e2)
end
-- 将自身送去墓地并丢弃1张手卡作为费用
function c37629703.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足将自身送去墓地和丢弃手卡的费用条件
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
	-- 丢弃1张手卡作为费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选「拉比林斯迷宫」魔法·陷阱卡的过滤函数
function c37629703.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x17e) and c:IsSSetable()
end
-- 设置效果的发动条件，检查手卡或卡组是否存在「拉比林斯迷宫」魔法·陷阱卡
function c37629703.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组是否存在「拉比林斯迷宫」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37629703.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
-- 选择并盖放一张「拉比林斯迷宫」魔法·陷阱卡
function c37629703.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的「拉比林斯迷宫」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c37629703.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 判断怪兽离场时是否为在怪兽区域离场且因效果离开
function c37629703.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 判断是否为己方的通常陷阱卡效果导致怪兽离场
function c37629703.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c37629703.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 设置效果发动时的处理目标为自身
function c37629703.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 将自身加入手卡的效果处理
function c37629703.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身加入手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
