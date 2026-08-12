--鉄の騎士
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「铁汉斯」存在的场合，这张卡的攻击力下降1000。
-- ②：场上的这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只「铁汉斯」加入手卡。场地区域有「急流山的金宫」存在的场合，可以作为代替从卡组把1只战士族怪兽加入手卡。
function c73405179.initial_effect(c)
	-- 注册卡片关联代码，表明这张卡的效果中记有「急流山的金宫」
	aux.AddCodeList(c,72283691)
	-- ①：自己场上有「铁汉斯」存在的场合，这张卡的攻击力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c73405179.atkcon)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：场上的这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只「铁汉斯」加入手卡。场地区域有「急流山的金宫」存在的场合，可以作为代替从卡组把1只战士族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73405179,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,73405179)
	e2:SetTarget(c73405179.thtg)
	e2:SetOperation(c73405179.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c73405179.thcon)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示存在的「铁汉斯」
function c73405179.filter(c)
	return c:IsFaceup() and c:IsCode(41916534)
end
-- 攻击力下降效果的发动条件：自己场上存在表侧表示的「铁汉斯」
function c73405179.atkcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的「铁汉斯」
	return Duel.IsExistingMatchingCard(c73405179.filter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 效果送墓触发条件：这张卡因效果从场上送去墓地
function c73405179.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索卡片的过滤条件：可以加入手卡的「铁汉斯」，或者在场上有「急流山的金宫」存在时，可以加入手卡的战士族怪兽
function c73405179.thfilter(c)
	-- 判断卡片是否为「铁汉斯」或者（在场上有「急流山的金宫」时）是否为战士族怪兽，且能加入手卡
	return (c:IsCode(41916534) or (Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE) and c:IsRace(RACE_WARRIOR))) and c:IsAbleToHand()
end
-- 检索效果的发动准备（检查卡组中是否存在可检索的卡，并设置将卡片加入手卡的操作信息）
function c73405179.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73405179.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统注册连锁处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理：从卡组选择1张符合条件的卡加入手卡，并给对方确认
function c73405179.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c73405179.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
