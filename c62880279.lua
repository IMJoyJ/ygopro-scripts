--ドドドドウォリアー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「怒怒怒」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级变成4星，攻击力变成1800。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「刷拉拉」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特召）和②效果（作为超量素材被取除时检索）。
function s.initial_effect(c)
	-- ①：从卡组把1只「怒怒怒」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级变成4星，攻击力变成1800。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除的场合才能发动。从卡组把1只「刷拉拉」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可作为代价送去墓地的「怒怒怒」怪兽。
function s.costfilter(c)
	return c:IsSetCard(0x82) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动代价：从卡组将1只「怒怒怒」怪兽送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可作为代价送去墓地的「怒怒怒」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择卡组中1只满足条件的「怒怒怒」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：特殊召唤自身，改变等级和攻击力，并施加额外卡组特殊召唤限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁相关，并尝试将其以表侧表示特殊召唤。
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡的等级变成4星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1,true)
		-- 攻击力变成1800。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(1800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(s.splimit)
	-- 注册该限制效果给玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 限制只能从额外卡组特殊召唤超量怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：此卡作为超量素材，为了发动超量怪兽的效果而被取除并送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤卡组中可加入手卡的「刷拉拉」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x8f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动准备：检查卡组中是否存在可检索的「刷拉拉」怪兽并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手卡的「刷拉拉」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组选择1只「刷拉拉」怪兽加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1只满足条件的「刷拉拉」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
