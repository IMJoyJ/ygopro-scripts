--Live☆Twin トラブルサン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「直播☆双子」怪兽加入手卡。
-- ②：只要自己场上有「邪恶★双子」怪兽存在，每次对方把怪兽召唤·特殊召唤，自己回复200基本分，给与对方200伤害。
function c37582948.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「直播☆双子」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37582948+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c37582948.activate)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「邪恶★双子」怪兽存在，每次对方把怪兽召唤·特殊召唤，自己回复200基本分，给与对方200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c37582948.reccon)
	e2:SetOperation(c37582948.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「直播☆双子」怪兽卡片组
function c37582948.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1151) and c:IsAbleToHand()
end
-- 效果处理：检索满足条件的「直播☆双子」怪兽并加入手牌
function c37582948.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「直播☆双子」怪兽卡片组
	local g=Duel.GetMatchingGroup(c37582948.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否满足发动条件并询问玩家是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(37582948,0)) then  --"是否从卡组把1只「直播☆双子」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认玩家选择的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断是否为对方召唤的怪兽
function c37582948.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断是否为「邪恶★双子」怪兽
function c37582948.etfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2151)
end
-- 效果触发条件：对方召唤或特殊召唤怪兽且己方场上有「邪恶★双子」怪兽
function c37582948.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方召唤或特殊召唤的怪兽中是否存在己方召唤的怪兽，且己方场上有「邪恶★双子」怪兽
	return eg:IsExists(c37582948.cfilter,1,nil,1-tp) and Duel.IsExistingMatchingCard(c37582948.etfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：回复LP并造成伤害
function c37582948.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示卡片发动动画
	Duel.Hint(HINT_CARD,0,37582948)
	-- 回复玩家基本分
	Duel.Recover(tp,200,REASON_EFFECT)
	-- 对对方造成伤害
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
