--イグナイト・バースト
-- 效果：
-- ①：1回合1次，自己主要阶段才能把这个效果发动。选这张卡以外的自己场上最多3张「点火骑士」卡破坏。那之后，选破坏数量的对方场上的卡回到持有者手卡。
-- ②：这张卡被送去墓地的场合才能发动。选自己的额外卡组1只表侧表示的「点火骑士」灵摆怪兽加入手卡。
function c65872270.initial_effect(c)
	-- “点火骑士炸裂”的卡片发动（可在发动时选择是否发动①的效果）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c65872270.target)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能把这个效果发动。选这张卡以外的自己场上最多3张「点火骑士」卡破坏。那之后，选破坏数量的对方场上的卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c65872270.descon)
	e2:SetTarget(c65872270.destg)
	e2:SetOperation(c65872270.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。选自己的额外卡组1只表侧表示的「点火骑士」灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c65872270.thtg)
	e3:SetOperation(c65872270.thop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的处理，并询问是否在发动时同时发动①的效果
function c65872270.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查是否满足①的效果发动条件，并询问玩家是否在卡片发动时同时发动该效果
	if c65872270.descon(e,tp,eg,ep,ev,re,r,rp) and c65872270.destg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(65872270,0)) then  --"是否使用效果？"
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
		e:SetOperation(c65872270.desop)
		c65872270.destg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- 检查当前是否为自己回合的主要阶段
function c65872270.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 检查当前阶段是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤场上表侧表示的「点火骑士」卡
function c65872270.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- ①的效果的发动准备（检查场上是否有可破坏的「点火骑士」卡和可回手牌的对方卡片，并设置破坏的操作信息）
function c65872270.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张这张卡以外的表侧表示「点火骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65872270.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张可以回到手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
		and e:GetHandler():GetFlagEffect(65872270)==0 end
	e:GetHandler():RegisterFlagEffect(65872270,RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁处理中的操作信息为破坏场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
-- ①的效果的实际处理（破坏自己场上的「点火骑士」卡，并让相同数量的对方场上的卡回到手牌）
function c65872270.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到手牌的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	local ct=g:GetCount()
	if ct==0 then return end
	if ct>3 then ct=3 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上最多等同于对方场上可回手牌卡片数量（且最多3张）的「点火骑士」卡
	local dg=Duel.SelectMatchingCard(tp,c65872270.desfilter,tp,LOCATION_ONFIELD,0,1,ct,e:GetHandler())
	-- 破坏选中的卡，并获取实际被破坏的卡片数量
	local ct2=Duel.Destroy(dg,REASON_EFFECT)
	if ct2>0 then
		-- 中断效果处理，使后续的“回到手牌”处理与“破坏”处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要回到手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		local rg=g:Select(tp,ct2,ct2,nil)
		-- 显式地在场上框选并展示对方被选中的卡片
		Duel.HintSelection(rg)
		-- 将选中的对方场上的卡片送回持有者手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
-- 过滤额外卡组中表侧表示且可以加入手牌的「点火骑士」灵摆怪兽
function c65872270.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToHand()
end
-- ②的效果的发动准备（检查额外卡组是否有符合条件的卡，并设置加入手牌的操作信息）
function c65872270.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组是否存在至少1只表侧表示的「点火骑士」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65872270.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理中的操作信息为从额外卡组将卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- ②的效果的实际处理（从额外卡组将1只表侧表示的「点火骑士」灵摆怪兽加入手牌）
function c65872270.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从额外卡组选择1只表侧表示的「点火骑士」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c65872270.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
