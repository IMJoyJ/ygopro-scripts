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
	-- 这张卡不能通常召唤。自己场上有「光子」怪兽或「银河」怪兽存在的场合可以特殊召唤。自己对「光子驱逐者」1回合只能有1次特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c43147039.sprcon)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「银河眼光子龙」加入手卡。
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
	-- ②：这张卡在特殊召唤的回合不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c43147039.atklimit)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这张卡战斗破坏的怪兽不去墓地而除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCondition(c43147039.effcon)
	e4:SetOperation(c43147039.effop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否表侧表示且拥有「光子」（0x55）或「银河」（0x7b）字段。
function c43147039.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 特殊召唤规则条件：c为nil时代表询问是否能特殊召唤（返回true）；实际召唤时要求自己场上有表侧表示的「光子」或「银河」怪兽，且主要怪兽区有空位。
function c43147039.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp玩家主要怪兽区是否有空余格子，保证有位置可以特殊召唤这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查tp玩家场上是否存在至少1张表侧表示且属于「光子」或「银河」字段的怪兽。
		and Duel.IsExistingMatchingCard(c43147039.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 检索过滤函数：只选择卡号为93717133（银河眼光子龙）且能够加入手卡的卡。
function c43147039.thfilter(c)
	return c:IsCode(93717133) and c:IsAbleToHand()
end
-- ①的发动条件和操作信息：满足卡组存在检索对象时，登记本次效果为从卡组将1张卡加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH）。
function c43147039.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中是否有符合条件的「银河眼光子龙」，没有则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c43147039.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次处理将把1张卡从卡组加入手卡，位置为卡组（LOCATION_DECK）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：玩家从卡组选择1只「银河眼光子龙」加入手卡，并向对方展示。
function c43147039.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家卡组中过滤并选择1张满足条件的「银河眼光子龙」。
	local g=Duel.SelectMatchingCard(tp,c43147039.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）送去持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果处理：特殊召唤成功后，为这张卡附加不能攻击的效果，该效果在结束阶段或离场等标准重置时解除。
function c43147039.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡在特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- ③的触发条件：仅当这张卡作为超量召唤的素材（r==REASON_XYZ）时，才赋予超量怪兽后续效果。
function c43147039.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- ③效果处理：以这张卡为素材超量召唤的怪兽获得“战斗破坏的怪兽不去墓地而除外”的效果；若该怪兽不是效果怪兽，则将其变为效果怪兽，确保效果正常适用。
function c43147039.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这张卡战斗破坏的怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(43147039,1))  --"「光子驱逐者」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。（若超量怪兽不是效果怪兽，则追加效果怪兽类型以赋予上述效果）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
