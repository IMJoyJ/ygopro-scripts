--マジェスティックP
-- 效果：
-- 「威风阵·飞马」的②的效果1回合只能使用1次。
-- ①：场上的「威风妖怪」怪兽的攻击力·守备力上升300。
-- ②：把自己场上1只魔法师族·风属性怪兽解放才能发动。从卡组把1只4星以下的「威风妖怪」怪兽特殊召唤。
function c76473843.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「威风妖怪」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的目标为字段名含有「威风妖怪」（0xd0）的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd0))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：把自己场上1只魔法师族·风属性怪兽解放才能发动。从卡组把1只4星以下的「威风妖怪」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(76473843,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,76473843)
	e4:SetCost(c76473843.spcost)
	e4:SetTarget(c76473843.sptg)
	e4:SetOperation(c76473843.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上的魔法师族·风属性怪兽，且解放后能空出足够的怪兽区域（若解放的是主怪兽区的怪兽则不受怪兽区数量限制，否则需要有空余怪兽区）。
function c76473843.cfilter(c,ft,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果②的发动代价（Cost）处理函数：检查并解放自己场上1只满足条件的魔法师族·风属性怪兽。
function c76473843.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 步骤0（检查是否可行）：检查玩家场上是否存在至少1只满足过滤条件、可被解放的怪兽，且解放后有足够的怪兽区域。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c76473843.cfilter,1,nil,ft,tp) end
	-- 过滤并让玩家选择1只满足条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c76473843.cfilter,1,1,nil,ft,tp)
	-- 将选中的怪兽作为发动代价（Cost）解放。
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动检查与效果分类注册（Target）函数。
function c76473843.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0（检查是否可行）：检查卡组中是否存在至少1只满足特殊召唤条件的4星以下「威风妖怪」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c76473843.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：此效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡组中属于「威风妖怪」（0xd0）字段、等级4以下且可以被特殊召唤的怪兽。
function c76473843.spfilter(c,e,tp)
	return c:IsSetCard(0xd0) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的效果处理（Operation）函数。
function c76473843.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍在场上，以及玩家场上是否有空余的怪兽区域，若不满足则不处理效果。
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c76473843.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
