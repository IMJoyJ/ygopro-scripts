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
-- 过滤函数，用于筛选卡组中满足条件的仪式怪兽（类型包含0x81且可以送去手卡）
function c23401839.filter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 效果的处理目标函数，检查卡组中是否存在满足条件的仪式怪兽并设置操作信息
function c23401839.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23401839.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，提示玩家选择仪式怪兽并将其加入手牌
function c23401839.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c23401839.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
