--黒竜降臨
-- 效果：
-- 「黑龙之圣骑士」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到4以上的怪兽解放，从手卡把「黑龙之圣骑士」仪式召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「真红眼」魔法·陷阱卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c18803791.initial_effect(c)
	-- 为这张卡添加仪式召唤效果：可将手卡·场上的合计等级直到4以上的怪兽解放，从手卡仪式召唤「黑龙之圣骑士」（71408082）。
	aux.AddRitualProcGreaterCode(c,71408082)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「真红眼」魔法·陷阱卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置效果的发动条件：该效果在这张卡送去墓地的回合不能发动。
	e1:SetCondition(aux.exccon)
	-- 设置效果的发动代价：把墓地里的这张卡除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c18803791.thtg)
	e1:SetOperation(c18803791.thop)
	c:RegisterEffect(e1)
end
-- 定义检索过滤条件：卡名属于「真红眼」字段、是魔法·陷阱卡且能够加入手卡。
function c18803791.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标判定与操作信息设置：确认卡组存在符合条件的「真红眼」魔法·陷阱卡，并设置本次操作为从卡组检索加入手牌。
function c18803791.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认自己卡组中存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c18803791.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将本次效果标记为从卡组把1张卡加入手牌的检索效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组选择1张符合条件的「真红眼」魔法·陷阱卡加入手牌，并展示给对方确认。
function c18803791.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选并选择1张符合条件的「真红眼」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c18803791.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
