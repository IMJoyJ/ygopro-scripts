--マンジュ・ゴッド
-- 效果：
-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只仪式怪兽或1张仪式魔法卡加入手卡。
function c95492061.initial_effect(c)
	-- ①：这张卡召唤·反转召唤时才能发动。从卡组把1只仪式怪兽或1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95492061,0))  --"把1只仪式怪兽或者1张仪式魔法卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c95492061.tg)
	e1:SetOperation(c95492061.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中属于仪式类型（仪式怪兽或仪式魔法）且能加入手牌的卡
function c95492061.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 效果①的发动条件检查与操作信息设置
function c95492061.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组中是否存在至少1张满足条件的仪式卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95492061.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将自己卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，从卡组选择1张仪式卡加入手牌并给对方确认
function c95492061.op(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端弹出提示，要求玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足过滤条件的仪式卡
	local g=Duel.SelectMatchingCard(tp,c95492061.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
