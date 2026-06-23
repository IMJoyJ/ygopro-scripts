--プランキッズ・ハウス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「调皮宝贝」怪兽加入手卡。
-- ②：1回合1次，自己对「调皮宝贝」融合怪兽的融合召唤成功的场合才能发动。自己场上的全部怪兽的攻击力上升500。
-- ③：1回合1次，自己对「调皮宝贝」连接怪兽的连接召唤成功的场合才能发动。对方场上的全部怪兽的攻击力下降500。
function c16269385.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「调皮宝贝」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16269385+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c16269385.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己对「调皮宝贝」融合怪兽的融合召唤成功的场合才能发动。自己场上的全部怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16269385,1))  --"自己全部怪兽攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c16269385.atkcon)
	e2:SetTarget(c16269385.atktg)
	e2:SetOperation(c16269385.atkop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己对「调皮宝贝」连接怪兽的连接召唤成功的场合才能发动。对方场上的全部怪兽的攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16269385,2))  --"对方全部怪兽攻击力下降"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16269385.atkcon2)
	e3:SetTarget(c16269385.atktg2)
	e3:SetOperation(c16269385.atkop2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「调皮宝贝」怪兽卡片组
function c16269385.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x120) and c:IsAbleToHand()
end
-- 发动时的效果处理，从卡组检索1只「调皮宝贝」怪兽加入手牌
function c16269385.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「调皮宝贝」怪兽卡片组
	local g=Duel.GetMatchingGroup(c16269385.thfilter,tp,LOCATION_DECK,0,nil)
	-- 判断是否满足检索条件并询问玩家是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16269385,0)) then  --"是否把「调皮宝贝」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断是否为「调皮宝贝」怪兽且满足召唤类型条件
function c16269385.cfilter(c,tp,sumt)
	return c:IsFaceup() and c:IsSetCard(0x120) and c:IsSummonType(sumt) and c:IsSummonPlayer(tp)
end
-- 判断是否有「调皮宝贝」融合怪兽特殊召唤成功
function c16269385.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16269385.cfilter,1,nil,tp,SUMMON_TYPE_FUSION)
end
-- 准备发动效果，检查自己场上是否有表侧表示怪兽
function c16269385.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- 将自己场上所有表侧表示怪兽的攻击力上升500
function c16269385.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 遍历自己场上所有表侧表示怪兽
	for tc in aux.Next(g) do
		-- 给目标怪兽增加500攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否有「调皮宝贝」连接怪兽特殊召唤成功
function c16269385.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16269385.cfilter,1,nil,tp,SUMMON_TYPE_LINK)
end
-- 准备发动效果，检查对方场上是否有表侧表示怪兽
function c16269385.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 将对方场上所有表侧表示怪兽的攻击力下降500
function c16269385.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上所有表侧表示怪兽
	for tc in aux.Next(g) do
		-- 给目标怪兽减少500攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
