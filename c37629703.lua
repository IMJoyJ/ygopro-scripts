--白銀の城の竜飾灯
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地，丢弃1张手卡才能发动。从手卡·卡组选1张「拉比林斯迷宫」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡加入手卡。
function c37629703.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡·场上的这张卡送去墓地，丢弃1张手卡才能发动。从手卡·卡组选1张「拉比林斯迷宫」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡加入手卡。
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
-- ①效果的cost处理函数：判定并执行把此卡从手卡·场上送去墓地、丢弃1张手卡的cost。chk==0时只检查可行性，实际支付时执行送墓与丢弃。
function c37629703.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost可行性检查：此卡能否作为cost送去墓地，以及手牌中是否存在1张可丢弃的手卡（此卡自身除外）。
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 将此卡作为cost送去墓地，原因标记为REASON_COST。
	Duel.SendtoGrave(c,REASON_COST)
	-- 从手牌丢弃1张手卡作为cost，原因标记为REASON_COST+REASON_DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义可盖放的卡的筛选条件：类型为魔法·陷阱卡，属于「拉比林斯迷宫」字段，且当前能够盖放到魔法·陷阱区。
function c37629703.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x17e) and c:IsSSetable()
end
-- ①效果的发动目标判定函数：在手牌·卡组中检查是否存在至少1张满足stfilter条件的「拉比林斯迷宫」魔法·陷阱卡，存在才能发动。
function c37629703.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动合法性检查）阶段确认手牌·卡组中存在满足条件的可盖放的「拉比林斯迷宫」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c37629703.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：让玩家从手牌·卡组选择1张符合条件的「拉比林斯迷宫」魔法·陷阱卡，并在自己场上盖放。
function c37629703.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示“请选择要盖放的卡”的提示消息，用于选择卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家实际从手牌·卡组中选择1张满足stfilter条件的「拉比林斯迷宫」魔法·陷阱卡，结果存入g。
	local g=Duel.SelectMatchingCard(tp,c37629703.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以里侧表示盖放到自己场上（魔法·陷阱区）。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 判断怪兽是否因卡的效果从场上离开：该卡之前位于主要怪兽区，且离场原因为REASON_EFFECT。
function c37629703.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- ②效果的发动条件：本连锁是由自己发动的通常陷阱卡的效果，且该效果让怪兽从场上离开；离开的怪兽集合eg中不包含墓地中的这张卡自身。
function c37629703.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c37629703.cfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ②效果的目标检查：确认墓地中的这张卡可以加入手卡，并设置操作信息为回手牌。
function c37629703.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置本次连锁的操作信息：分类为CATEGORY_TOHAND，对象为墓地中的这张卡，数量1，用于外界时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若墓地中的这张卡仍与发动时的效果保持关联，则将其加入手卡。
function c37629703.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡从墓地加入持有者手卡，原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
