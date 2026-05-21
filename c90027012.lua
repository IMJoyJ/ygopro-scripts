--チョウジュ・ゴッド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只仪式怪兽和1张仪式魔法卡加入手卡。
function c90027012.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从卡组把1只仪式怪兽和1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90027012,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,90027012)
	e1:SetTarget(c90027012.tg)
	e1:SetOperation(c90027012.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手牌的仪式怪兽
function c90027012.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤卡组中可以加入手牌的仪式魔法卡
function c90027012.filter2(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动的可行性检查：检查卡组中是否同时存在可加入手牌的仪式怪兽和仪式魔法卡
function c90027012.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以加入手牌的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90027012.filter,tp,LOCATION_DECK,0,1,nil)
		-- 以及检查卡组中是否存在至少1张可以加入手牌的仪式魔法卡
		and Duel.IsExistingMatchingCard(c90027012.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：检查卡组中是否依然同时存在可加入手牌的仪式怪兽和仪式魔法卡
function c90027012.op(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在至少1只可以加入手牌的仪式怪兽
	if not (Duel.IsExistingMatchingCard(c90027012.filter,tp,LOCATION_DECK,0,1,nil)
		-- 以及检查卡组中是否存在至少1张可以加入手牌的仪式魔法卡，若不满足则不处理
		and Duel.IsExistingMatchingCard(c90027012.filter2,tp,LOCATION_DECK,0,1,nil)) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c90027012.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张仪式魔法卡
	local g2=Duel.SelectMatchingCard(tp,c90027012.filter2,tp,LOCATION_DECK,0,1,1,nil)
	g:Merge(g2)
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 给对方玩家确认加入手牌的卡
	Duel.ConfirmCards(1-tp,g)
end
