--暴走召喚師アレイスター
-- 效果：
-- 种族和属性不同的怪兽2只
-- ①：这张卡的卡名只要在场上·墓地存在当作「召唤师 阿莱斯特」使用。
-- ②：这张卡已在怪兽区域存在的状态，融合怪兽融合召唤的场合才能发动。选自己1张手卡丢弃，从卡组把1张「召唤魔术」或者「法之圣典」加入手卡。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组把1张「魔法名-「大兽」」加入手卡。
function c97973962.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,74063034,458748,47457347)
	aux.AddLinkProcedure(c,nil,2,2,c97973962.spcheck)
	-- 使这张卡在怪兽区域和墓地存在时，卡名当作「召唤师 阿莱斯特」使用
	aux.EnableChangeCode(c,86120751,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡已在怪兽区域存在的状态，融合怪兽融合召唤的场合才能发动。选自己1张手卡丢弃，从卡组把1张「召唤魔术」或者「法之圣典」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97973962,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c97973962.thcon)
	e2:SetTarget(c97973962.thtg)
	e2:SetOperation(c97973962.thop)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组把1张「魔法名-「大兽」」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97973962,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c97973962.thcon2)
	e3:SetTarget(c97973962.thtg2)
	e3:SetOperation(c97973962.thop2)
	c:RegisterEffect(e3)
end
-- 检查连接素材是否为种族和属性各不相同的怪兽
function c97973962.spcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount() and g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
-- 效果②的发动条件：有融合怪兽融合召唤成功
function c97973962.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_FUSION)
end
-- 过滤卡组中可以加入手牌的「召唤魔术」或「法之圣典」
function c97973962.thfilter(c)
	return c:IsCode(74063034,458748) and c:IsAbleToHand()
end
-- 效果②的发动准备，检查手牌和卡组中是否存在符合条件的卡，并设置操作信息
function c97973962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查卡组中是否存在可以加入手牌的「召唤魔术」或「法之圣典」
		and Duel.IsExistingMatchingCard(c97973962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含丢弃1张手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置操作信息，表示此效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：丢弃1张手牌，从卡组将1张「召唤魔术」或「法之圣典」加入手牌
function c97973962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 选自己1张手卡丢弃，若成功丢弃则继续执行
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「召唤魔术」或「法之圣典」
		local g=Duel.SelectMatchingCard(tp,c97973962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡片加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手牌的卡片给对方确认
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果③的发动条件：表侧表示的自身因对方的效果从场上离开
function c97973962.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT))	and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤卡组中可以加入手牌的「魔法名-「大兽」」
function c97973962.thfilter2(c)
	return c:IsCode(47457347) and c:IsAbleToHand()
end
-- 效果③的发动准备，检查卡组中是否存在「魔法名-「大兽」」并设置操作信息
function c97973962.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「魔法名-「大兽」」
	if chk==0 then return Duel.IsExistingMatchingCard(c97973962.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理：从卡组将1张「魔法名-「大兽」」加入手牌
function c97973962.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「魔法名-「大兽」」
	local g=Duel.SelectMatchingCard(tp,c97973962.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
