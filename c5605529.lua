--ヴァルモニカ・シェルタ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从以下效果选1个适用。自己的灵摆区域没有「异响鸣」卡存在的场合，适用的效果由对方来选。
-- ●自己回复500基本分。那之后，可以选自己1张手卡回到卡组最下面。那个场合，自己抽2张。
-- ●自己受到500伤害。那之后，可以从卡组把「异响鸣的选择」以外的1张「异响鸣」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片发动时的效果，设置效果分类、类型、时点、1回合1次限制及处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从以下效果选1个适用。自己的灵摆区域没有「异响鸣」卡存在的场合，适用的效果由对方来选。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_DAMAGE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「异响鸣的选择」以外的「异响鸣」魔法·陷阱卡。
function s.filter(c)
	return c:IsSetCard(0x1a3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果处理的核心逻辑，根据灵摆区是否有「异响鸣」卡决定由谁选择效果，并执行对应的回复/抽卡或伤害/检索处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp,op)
	if op==nil then
		-- 检查自己灵摆区是否存在「异响鸣」卡，若存在则由自己选择效果，否则由对方选择。
		local p=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,0x1a3) and tp or 1-tp
		op=aux.SelectFromOptions(p,{true,aux.Stringid(id,1)},{true,aux.Stringid(id,2)})  --"自己回复500基本分/自己受到500伤害"
	end
	if op==1 then
		-- 玩家回复500基本分，若回复数值小于1则不进行后续处理。
		if Duel.Recover(tp,500,REASON_EFFECT)<1 then return end
		-- 获取玩家手牌中可以回到卡组的卡片组。
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
		-- 检查手牌是否有卡、玩家是否能抽2张卡，并询问玩家是否选择将手牌回到卡组并抽卡。
		if #g>0 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把自己手卡回到卡组并抽卡？"
			-- 提示玩家选择要送回卡组的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 选中卡片的视觉提示。
			Duel.HintSelection(sg)
			-- 中断当前效果，使后续的送回卡组和抽卡处理与回复LP不视为同时进行。
			Duel.BreakEffect()
			-- 将选中的手牌送回卡组最下面。
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			if sg:GetFirst():IsLocation(LOCATION_DECK) then
				-- 玩家从卡组抽2张卡。
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	-- 否则（选择第二个效果时），玩家受到500点伤害，若成功受到伤害则继续处理。
	elseif Duel.Damage(tp,500,REASON_EFFECT)>0 then
		-- 获取卡组中满足过滤条件的「异响鸣」魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		-- 检查卡组中是否有符合条件的卡，并询问玩家是否选择将卡加入手卡。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否从卡组把卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果，使后续的检索处理与受到伤害不视为同时进行。
			Duel.BreakEffect()
			-- 将选中的卡加入玩家手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
