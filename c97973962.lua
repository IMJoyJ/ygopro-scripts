--暴走召喚師アレイスター
-- 效果：
-- 种族和属性不同的怪兽2只
-- ①：这张卡的卡名只要在场上·墓地存在当作「召唤师 阿莱斯特」使用。
-- ②：这张卡已在怪兽区域存在的状态，融合怪兽融合召唤的场合才能发动。选自己1张手卡丢弃，从卡组把1张「召唤魔术」或者「法之圣典」加入手卡。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组把1张「魔法名-「大兽」」加入手卡。
function c97973962.initial_effect(c)
	c:EnableReviveLimit()
	-- 记录该卡记载了「召唤魔术」、「法之圣典」以及「魔法名-「大兽」」的卡名
	aux.AddCodeList(c,74063034,458748,47457347)
	-- 添加连接召唤手续：种族和属性不同的怪兽2只
	aux.AddLinkProcedure(c,nil,2,2,c97973962.spcheck)
	-- 这张卡的卡名只要在场上·墓地存在当作「召唤师 阿莱斯特」使用
	aux.EnableChangeCode(c,86120751,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡在怪兽区域存在的状态，融合怪兽融合召唤的场合才能发动。选自己1张手卡丢弃，从卡组把1张「召唤魔术」或「法之圣典」加入手卡。
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
-- 连接素材的属性与种族检查函数：要求素材组内所有怪兽的种族和属性都各不相同
function c97973962.spcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount() and g:GetClassCount(Card.GetLinkAttribute)==g:GetCount()
end
-- 效果②的发动条件：有融合怪兽特殊召唤成功
function c97973962.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_FUSION)
end
-- 过滤函数：从卡组检索「召唤魔术」或「法之圣典」且能加入手牌的卡
function c97973962.thfilter(c)
	return c:IsCode(74063034,458748) and c:IsAbleToHand()
end
-- 效果②的发动判定与效果处理目标设置
function c97973962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时判定自己手牌是否有至少1张卡可以用于丢弃
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 并且卡组里存在满足检索条件的卡
		and Duel.IsExistingMatchingCard(c97973962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的分类为丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置效果处理的分类为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理函数：丢弃1张手牌，从卡组将1张「召唤魔术」或「法之圣典」加入手牌
function c97973962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择并因效果丢弃1张手牌，成功丢弃后才执行后续处理
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1张「召唤魔术」或「法之圣典」
		local g=Duel.SelectMatchingCard(tp,c97973962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认加入手牌的卡给对方看
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果③的发动条件：表侧表示的自身因对方的效果从场上离开
function c97973962.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT))	and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数：从卡组检索「魔法名-「大兽」」且能加入手牌的卡
function c97973962.thfilter2(c)
	return c:IsCode(47457347) and c:IsAbleToHand()
end
-- 效果③的发动判定与效果处理目标设置（检索「魔法名-「大兽」」）
function c97973962.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时判定自己卡组是否有「魔法名-「大兽」」可以检索
	if chk==0 then return Duel.IsExistingMatchingCard(c97973962.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的分类为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理函数：从卡组把1张「魔法名-「大兽」」加入手卡
function c97973962.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「魔法名-「大兽」」
	local g=Duel.SelectMatchingCard(tp,c97973962.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认加入手牌的卡给对方看
		Duel.ConfirmCards(1-tp,g)
	end
end
