--フォトン・バニッシャー
-- 效果：
-- 这张卡不能通常召唤。自己场上有「光子」怪兽或「银河」怪兽存在的场合可以特殊召唤。自己对「光子驱逐者」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「银河眼光子龙」加入手卡。
-- ②：这张卡在特殊召唤的回合不能攻击。
-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡战斗破坏的怪兽不去墓地而除外。
function c43147039.initial_effect(c)
	c:SetSPSummonOnce(43147039)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「银河眼光子龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c43147039.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在特殊召唤的回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43147039,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,43147039)
	e2:SetTarget(c43147039.thtg)
	e2:SetOperation(c43147039.thop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这张卡战斗破坏的怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c43147039.atklimit)
	c:RegisterEffect(e3)
	-- 自己场上有「光子」怪兽或「银河」怪兽存在的场合可以特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCondition(c43147039.effcon)
	e4:SetOperation(c43147039.effop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在「光子」或「银河」怪兽。
function c43147039.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 判断特殊召唤条件是否满足：场上存在「光子」或「银河」怪兽且有空位。
function c43147039.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家场上是否存在至少1只「光子」或「银河」怪兽。
		and Duel.IsExistingMatchingCard(c43147039.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断卡组中是否存在「银河眼光子龙」。
function c43147039.thfilter(c)
	return c:IsCode(93717133) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，确定要检索的卡为「银河眼光子龙」。
function c43147039.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在「银河眼光子龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c43147039.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，确定要检索的卡为「银河眼光子龙」。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌。
function c43147039.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只「银河眼光子龙」。
	local g=Duel.SelectMatchingCard(tp,c43147039.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置效果，使该回合不能攻击。
function c43147039.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 使该回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判断是否为超量召唤作为素材。
function c43147039.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 设置效果，使战斗破坏的怪兽除外。
function c43147039.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 设置效果，使战斗破坏的怪兽除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(43147039,1))  --"「光子驱逐者」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若目标怪兽不是效果怪兽，则添加效果怪兽类型。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
