--化石調査
-- 效果：
-- ①：从卡组把1只6星以下的恐龙族怪兽加入手卡。
function c47325505.initial_effect(c)
	-- ①：从卡组把1只6星以下的恐龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c47325505.target)
	e1:SetOperation(c47325505.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：等级6以下、恐龙族、且能被加入手卡的怪兽（用于从卡组检索）。
function c47325505.filter(c)
	return c:IsLevelBelow(6) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：检查卡组是否存在满足条件的恐龙族怪兽，并设置本次效果处理为将1张卡加入手卡。
function c47325505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查（chk==0）：确认卡组存在至少1只满足条件的恐龙族怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c47325505.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果的操作信息：本次效果将处理的对象为卡组中的1张卡，分类为加入手卡（用于星尘龙等效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：由玩家从卡组选择1只满足条件的恐龙族怪兽加入手卡，并让对手确认。
function c47325505.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选择1张满足过滤条件（6星以下恐龙族且能加入手卡）的卡。
	local g=Duel.SelectMatchingCard(tp,c47325505.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡（REASON_EFFECT表示因效果加入手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
