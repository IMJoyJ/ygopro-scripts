--鎧竜の聖騎士
-- 效果：
-- 「铠龙降临」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只怪兽回到持有者卡组。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只5星以上的龙族·风属性怪兽特殊召唤。
function c75901113.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：从额外卡组特殊召唤的怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75901113,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,75901113)
	e1:SetCondition(c75901113.tdcon)
	e1:SetTarget(c75901113.tdtg)
	e1:SetOperation(c75901113.tdop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只5星以上的龙族·风属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75901113,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,75901114)
	e2:SetCost(c75901113.cost)
	e2:SetTarget(c75901113.target)
	e2:SetOperation(c75901113.activate)
	c:RegisterEffect(e2)
end
-- 判断与这张卡进行战斗的怪兽是否是从额外卡组特殊召唤的怪兽
function c75901113.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动准备，确认进行战斗的怪兽存在、在场上且能回到卡组，并设置操作信息
function c75901113.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsAbleToDeck() end
	-- 设置操作信息为将进行战斗的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,bc,1,0,0)
end
-- 效果①的处理，将进行战斗的怪兽送回持有者卡组并洗牌
function c75901113.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc:IsRelateToBattle() then return false end
	-- 将进行战斗的怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 效果②的代价，确认自身可以解放并将其解放
function c75901113.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：5星以上的龙族·风属性怪兽，且可以特殊召唤
function c75901113.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备，确认解放自身后有可用的怪兽区域，且手卡·卡组存在满足条件的怪兽，并设置特殊召唤的操作信息
function c75901113.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放自身后是否有可用的怪兽区域，以及手卡或卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and Duel.IsExistingMatchingCard(c75901113.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理，从手卡·卡组选择1只满足条件的怪兽特殊召唤
function c75901113.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c75901113.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
