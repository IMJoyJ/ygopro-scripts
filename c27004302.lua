--ジェムレシス
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只「宝石骑士」怪兽加入手卡。
function c27004302.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只「宝石骑士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27004302,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27004302.target)
	e1:SetOperation(c27004302.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否为「宝石骑士」字段的怪兽卡，且能够加入手卡。
function c27004302.filter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标函数：进行发动合法性检查（是否有符合条件的卡），并设置效果处理时的操作信息。
function c27004302.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查我方卡组是否存在1张以上满足过滤条件的「宝石骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c27004302.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时涉及将卡组中的1张卡加入手卡（CATEGORY_TOHAND），对象数量为1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理时的操作函数：从卡组检索1只符合条件的「宝石骑士」怪兽加入手卡，并让对手确认。
function c27004302.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家弹出选择提示，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的「宝石骑士」怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c27004302.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手玩家确认被检索并加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
