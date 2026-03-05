--黒竜降臨
-- 效果：
-- 「黑龙之圣骑士」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到4以上的怪兽解放，从手卡把「黑龙之圣骑士」仪式召唤。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「真红眼」魔法·陷阱卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c18803791.initial_effect(c)
	-- 为卡片添加等级可以超过仪式怪兽原本等级的仪式召唤效果，仪式怪兽卡号为71408082
	aux.AddRitualProcGreaterCode(c,71408082)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「真红眼」魔法·陷阱卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置效果条件为：这张卡不能在送去墓地的回合发动
	e1:SetCondition(aux.exccon)
	-- 设置效果代价为：把这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c18803791.thtg)
	e1:SetOperation(c18803791.thop)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于检索满足条件的「真红眼」魔法·陷阱卡
function c18803791.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义效果的处理目标函数，检查卡组中是否存在满足条件的卡并设置操作信息
function c18803791.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18803791.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理函数，选择并把符合条件的卡加入手牌
function c18803791.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c18803791.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
