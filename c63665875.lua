--ゴブリンゾンビ
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合发动。对方卡组最上面的卡送去墓地。
-- ②：这张卡从场上送去墓地的场合发动。从卡组把1只守备力1200以下的不死族怪兽加入手卡。
function c63665875.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害的场合发动。对方卡组最上面的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63665875,0))  --"对方卡组最上面的1张卡送去墓地"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c63665875.ddcon)
	e1:SetTarget(c63665875.ddtg)
	e1:SetOperation(c63665875.ddop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合发动。从卡组把1只守备力1200以下的不死族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63665875,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c63665875.srcon)
	e2:SetTarget(c63665875.srtg)
	e2:SetOperation(c63665875.srop)
	c:RegisterEffect(e2)
end
-- 判断受到战斗伤害的玩家是否为对方（即自己给与对方战斗伤害）
function c63665875.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果①的靶向与发动检测，设置将对方卡组最上方的卡送去墓地的操作信息
function c63665875.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方卡组最上方的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
end
-- 效果①的操作函数，执行将对方卡组最上方的卡送去墓地的处理
function c63665875.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上方的1张卡送去墓地
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
-- 判断这张卡之前的位置是否在场上（即是否从场上送去墓地）
function c63665875.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的靶向与发动检测，设置从卡组将1张卡加入手卡的操作信息
function c63665875.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：守备力1200以下的不死族且可以加入手卡的怪兽
function c63665875.filter(c)
	return c:IsDefenseBelow(1200) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- 效果②的操作函数，从卡组选择1只符合条件的怪兽加入手卡并给对方确认
function c63665875.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c63665875.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
