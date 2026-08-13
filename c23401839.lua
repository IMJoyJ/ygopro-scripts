--センジュ・ゴッド
-- 效果：
-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只仪式怪兽加入手卡。
function c23401839.initial_effect(c)
	-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23401839,0))  --"选择1张仪式怪兽卡加入自己手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c23401839.tg)
	e1:SetOperation(c23401839.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：仅当卡片是仪式怪兽且能够加入手卡时返回真，用于从卡组筛选可加入手卡的仪式怪兽。
function c23401839.filter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 发动时检查卡组是否有符合条件的仪式怪兽，若有则允许发动；并设置操作信息为从卡组将1张卡加入手牌。
function c23401839.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查玩家卡组中是否存在至少1只符合c23401839.filter条件的仪式怪兽，作为能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c23401839.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理涉及将卡加入手牌，预期从玩家tp的卡组中将1张卡加入手牌（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先向玩家提示选择，再从卡组选择1只符合条件的仪式怪兽加入手牌，并向对方展示加入手牌的卡。
function c23401839.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp发送‘请选择要加入手牌的卡’的选牌提示，用于选择加入手牌的卡片时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家tp的卡组中，以c23401839.filter为过滤条件，选择1张仪式怪兽（数量1）。
	local g=Duel.SelectMatchingCard(tp,c23401839.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因（REASON_EFFECT）加入其持有者的手卡（nil表示加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家（1-tp），以确认检索到的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
