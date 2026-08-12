--最果ての宇宙
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有鱼族同调怪兽存在，这张卡不会被效果破坏，不能用效果除外。
-- ②：从自己的手卡·墓地把1只鱼族怪兽除外才能发动。从卡组把1只「魊影」怪兽加入手卡。
-- ③：这张卡在墓地存在的状态，自己场上有鱼族怪兽召唤·特殊召唤的场合，以自己场上1只鱼族怪兽为对象才能发动。那只怪兽除外，这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有鱼族同调怪兽存在，这张卡不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有鱼族同调怪兽存在，不能用效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
	e2:SetCondition(s.indescon)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·墓地把1只鱼族怪兽除外才能发动。从卡组把1只「魊影」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的状态，自己场上有鱼族怪兽召唤·特殊召唤的场合，以自己场上1只鱼族怪兽为对象才能发动。那只怪兽除外，这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(s.rcon)
	e4:SetTarget(s.rtg)
	e4:SetOperation(s.rop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示的鱼族同调怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FISH)
end
-- 效果①的启用条件：自己场上存在鱼族同调怪兽
function s.indescon(e)
	-- 检查自己场上是否存在鱼族同调怪兽
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 除外限制过滤器：限制自身因效果而被除外
function s.rmlimit(e,c,tp,r,re)
	return c==e:GetHandler() and r&REASON_EFFECT>0
end
-- 过滤条件：手卡·墓地可以除外的鱼族怪兽
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从手卡·墓地将1只鱼族怪兽除外
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·墓地是否存在可作为代价除外的鱼族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择手卡·墓地1只鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中可以加入手卡的「魊影」怪兽
function s.sfilter(c)
	return c:IsSetCard(0x18a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在可检索的「魊影」怪兽并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「魊影」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只「魊影」怪兽加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只「魊影」怪兽
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的鱼族怪兽
function s.vfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsControler(tp)
end
-- 效果③的发动条件：自己场上有鱼族怪兽召唤·特殊召唤
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.vfilter,1,nil,tp)
end
-- 过滤条件：自己场上表侧表示且可以除外的鱼族怪兽
function s.rfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemove()
end
-- 效果③的发动准备：以自己场上1只鱼族怪兽为对象，并设置操作信息
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.rfilter(chkc) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在可作为对象的鱼族怪兽，且墓地的这张卡是否能加入手卡
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsAbleToHand() end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只鱼族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：除外对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果③的效果处理：将对象怪兽除外，并将这张卡加入手卡
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽除外，若除外失败则不处理后续效果
	if not (tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0) then return end
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将这张卡加入手卡
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
