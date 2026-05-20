--召魔装着
-- 效果：
-- ①：自己场上的龙族·战士族·魔法师族怪兽的攻击力·守备力上升300。
-- ②：1回合1次，丢弃1张手卡才能发动。从卡组把1只「魔装战士」怪兽特殊召唤。
-- ③：1回合1次，把自己墓地的战士族·魔法师族怪兽合计4只除外才能发动。从卡组把1只「以太神兵龙」怪兽加入手卡。
function c54250060.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的龙族·战士族·魔法师族怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为龙族、战士族或魔法师族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON+RACE_WARRIOR+RACE_SPELLCASTER))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，丢弃1张手卡才能发动。从卡组把1只「魔装战士」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54250060,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c54250060.spcost)
	e4:SetTarget(c54250060.sptg)
	e4:SetOperation(c54250060.spop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，把自己墓地的战士族·魔法师族怪兽合计4只除外才能发动。从卡组把1只「以太神兵龙」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(54250060,1))  --"卡组检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c54250060.thcost)
	e5:SetTarget(c54250060.thtg)
	e5:SetOperation(c54250060.thop)
	c:RegisterEffect(e5)
end
-- 效果②的代价（Cost）处理函数
function c54250060.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段（chk==0），检查手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST,nil)
end
-- 过滤函数：检查卡片是否为「魔装战士」怪兽且可以被特殊召唤
function c54250060.spfilter(c,e,tp)
	return c:IsSetCard(0xca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）处理函数
function c54250060.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只满足特殊召唤条件的「魔装战士」怪兽
		and Duel.IsExistingMatchingCard(c54250060.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数
function c54250060.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特殊召唤条件的「魔装战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c54250060.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检查卡片是否为墓地的战士族或魔法师族怪兽，且可以作为代价除外
function c54250060.cfilter(c)
	return c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER) and c:IsAbleToRemoveAsCost()
end
-- 效果③的代价（Cost）处理函数
function c54250060.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查自己墓地是否存在至少4只满足条件的战士族或魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54250060.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择4只满足条件的战士族或魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c54250060.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	-- 将选中的4只怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：检查卡片是否为卡组中的「以太神兵龙」怪兽且可以加入手卡
function c54250060.thfilter(c)
	return c:IsSetCard(0xcb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的发动准备（Target）处理函数
function c54250060.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查卡组中是否存在至少1只可以加入手卡的「以太神兵龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54250060.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（Operation）函数
function c54250060.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只「以太神兵龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c54250060.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
