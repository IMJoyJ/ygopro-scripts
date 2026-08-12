--風霊媒師ウィン
-- 效果：
-- 这个卡名在规则上也当作「灵使」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只风属性怪兽丢弃才能发动。除「风灵媒师 薇茵」外的1只守备力1500以下的风属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把风属性以外的怪兽的效果发动。
-- ②：自己的风属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
function c86395581.initial_effect(c)
	-- ①：从手卡把这张卡和1只风属性怪兽丢弃才能发动。除「风灵媒师 薇茵」外的1只守备力1500以下的风属性怪兽从卡组加入手卡。这个效果的发动后，直到回合结束时自己不能把风属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86395581,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,86395581)
	e1:SetCost(c86395581.srcost)
	e1:SetTarget(c86395581.srtg)
	e1:SetOperation(c86395581.srop)
	c:RegisterEffect(e1)
	-- ②：自己的风属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86395581,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,86395582)
	e2:SetCondition(c86395581.spcon)
	e2:SetTarget(c86395581.sptg)
	e2:SetOperation(c86395581.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可丢弃的风属性怪兽
function c86395581.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable()
end
-- 过滤卡组中除「风灵媒师 薇茵」以外、守备力1500以下且能加入手牌的风属性怪兽
function c86395581.srfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDefenseBelow(1500) and not c:IsCode(86395581) and c:IsAbleToHand()
end
-- 效果①的发动代价（从手卡把这张卡和1只风属性怪兽丢弃）
function c86395581.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在除这张卡以外的可丢弃风属性怪兽，且这张卡自身也可丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(c86395581.filter,tp,LOCATION_HAND,0,1,c) and c:IsDiscardable() end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择手卡中除这张卡以外的1只风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c86395581.filter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的怪兽和这张卡作为代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动准备与合法性检查（检索卡组中满足条件的怪兽）
function c86395581.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86395581.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（检索怪兽并适用“不能发动风属性以外怪兽效果”的限制）
function c86395581.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c86395581.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把风属性以外的怪兽的效果发动。②：自己的风属性怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c86395581.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家限制效果，使其在回合结束前生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的怪兽属性（非风属性怪兽不能发动效果）
function c86395581.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_WIND)
end
-- 过滤被战斗破坏前在场上表侧表示存在的己方风属性怪兽
function c86395581.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WIND)~=0
end
-- 效果②的发动条件检查（自己的风属性怪兽被战斗破坏，且被破坏的卡不含手卡中的这张卡本身）
function c86395581.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86395581.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动准备与合法性检查（特殊召唤自身）
function c86395581.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否能特殊召唤，且己方主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为“特殊召唤这张卡”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理（特殊召唤自身）
function c86395581.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
