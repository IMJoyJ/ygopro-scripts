--電子光虫－LEDバグ
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
-- ①：1回合1次，表侧攻击表示的这张卡变成守备表示时才能发动。从卡组把1只昆虫族·3星怪兽加入手卡。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡战斗破坏怪兽时自己从卡组抽1张。
function c83048208.initial_effect(c)
	-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c83048208.xyzlimit)
	c:RegisterEffect(e0)
	-- ①：1回合1次，表侧攻击表示的这张卡变成守备表示时才能发动。从卡组把1只昆虫族·3星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83048208,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCountLimit(1)
	e1:SetCondition(c83048208.thcon)
	e1:SetTarget(c83048208.thtg)
	e1:SetOperation(c83048208.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c83048208.efcon)
	e2:SetOperation(c83048208.efop)
	c:RegisterEffect(e2)
end
-- 限制该卡只能作为昆虫族怪兽的超量召唤素材
function c83048208.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
-- 检查是否满足表侧攻击表示的这张卡变成守备表示的发动条件
function c83048208.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_CONTINUOUS_POS) and c:IsPosition(POS_FACEUP_DEFENSE) and c:IsPreviousPosition(POS_FACEUP_ATTACK)
end
-- 过滤卡组中满足昆虫族、3星且能加入手牌的怪兽
function c83048208.thfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsLevel(3) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在符合条件的卡并设置操作信息
function c83048208.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的昆虫族·3星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83048208.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，从卡组选择1只昆虫族·3星怪兽加入手牌并给对方确认
function c83048208.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的昆虫族·3星怪兽
	local g=Duel.SelectMatchingCard(tp,c83048208.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查是否作为超量召唤素材
function c83048208.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 为超量召唤的怪兽赋予战斗破坏怪兽时抽卡的效果，若该怪兽不是效果怪兽则为其添加效果怪兽类型
function c83048208.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡战斗破坏怪兽时自己从卡组抽1张。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(83048208,1))  --"「电子光虫-LED瓢虫」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetOperation(c83048208.drop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡战斗破坏怪兽时自己从卡组抽1张。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 赋予效果的抽卡处理
function c83048208.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显示「电子光虫-LED瓢虫」的卡片发动提示
	Duel.Hint(HINT_CARD,0,83048208)
	-- 让玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
