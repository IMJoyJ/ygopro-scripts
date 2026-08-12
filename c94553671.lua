--ウィッチクラフト・パトローナス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只魔法师族怪兽为对象才能发动。那只怪兽回到卡组，从卡组把1张「魔女术」魔法卡加入手卡。
-- ②：把墓地的这张卡除外，以除外的自己的「魔女术」魔法卡任意数量为对象才能发动（同名卡最多1张）。那些卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c94553671.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以1只魔法师族怪兽为对象才能发动。那只怪兽回到卡组，从卡组把1张「魔女术」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94553671,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,94553671)
	e2:SetTarget(c94553671.srtg)
	e2:SetOperation(c94553671.srop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以除外的自己的「魔女术」魔法卡任意数量为对象才能发动（同名卡最多1张）。那些卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94553671,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,94553672)
	-- 设置效果2的发动条件：这张卡送去墓地的回合不能发动。
	e3:SetCondition(aux.exccon)
	-- 设置效果2的发动Cost：把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c94553671.thtg)
	e3:SetOperation(c94553671.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地或除外状态的、可回到卡组的魔法师族怪兽。
function c94553671.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToDeck()
end
-- 过滤条件：卡组中可加入手卡的「魔女术」魔法卡。
function c94553671.srfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x128) and c:IsAbleToHand()
end
-- 效果1的发动准备与目标选择。
function c94553671.srtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c94553671.tdfilter(chkc) end
	-- 检查自己墓地或除外区是否存在至少1只满足条件的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c94553671.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 并且检查自己卡组中是否存在至少1张可检索的「魔女术」魔法卡。
		and Duel.IsExistingMatchingCard(c94553671.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要回到卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地或除外区的1只魔法师族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c94553671.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置效果处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的处理逻辑（回到卡组并检索）。
function c94553671.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果1的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍适应效果，则将其送回卡组并洗牌；若成功回到卡组，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「魔女术」魔法卡。
		local g=Duel.SelectMatchingCard(tp,c94553671.srfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「魔女术」魔法卡加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 过滤条件：除外状态的、表侧表示的「魔女术」魔法卡。
function c94553671.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果2的发动准备与目标选择（任意数量且同名卡最多1张）。
function c94553671.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c94553671.thfilter(chkc) end
	-- 检查除外区是否存在至少1张满足条件的「魔女术」魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c94553671.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 获取除外区所有满足条件且能成为效果对象的「魔女术」魔法卡。
	local g=Duel.GetMatchingGroup(c94553671.thfilter,tp,LOCATION_REMOVED,0,nil):Filter(Card.IsCanBeEffectTarget,nil,e)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 允许玩家选择任意数量（1张以上）且卡名互不相同的卡片。
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,g:GetCount())
	-- 将选择的卡片群设为效果对象。
	Duel.SetTargetCard(tg)
	-- 设置效果处理信息：将选中的卡片加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,tg:GetCount(),0,0)
end
-- 效果2的处理逻辑（将选中的除外卡片加入手卡）。
function c94553671.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍适应效果的对象卡片。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些卡片加入手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
