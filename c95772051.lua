--魔聖騎士ランスロット
-- 效果：
-- 把自己场上表侧表示存在的1只光属性的通常怪兽送去墓地才能发动。这张卡从手卡或者墓地特殊召唤。此外，把自己场上1只名字带有「圣骑士」的怪兽解放才能发动。从卡组把1张名字带有「圣剑」的卡加入手卡。「魔圣骑士 兰斯洛特」的这个效果1回合只能使用1次。此外，「魔圣骑士 兰斯洛特」在自己场上只能有1只表侧表示存在。
function c95772051.initial_effect(c)
	c:SetUniqueOnField(1,0,95772051)
	-- 把自己场上表侧表示存在的1只光属性的通常怪兽送去墓地才能发动。这张卡从手卡或者墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95772051,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(c95772051.spcost)
	e1:SetTarget(c95772051.sptg)
	e1:SetOperation(c95772051.spop)
	c:RegisterEffect(e1)
	-- 此外，把自己场上1只名字带有「圣骑士」的怪兽解放才能发动。从卡组把1张名字带有「圣剑」的卡加入手卡。「魔圣骑士 兰斯洛特」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95772051,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,95772051)
	e2:SetCost(c95772051.thcost)
	e2:SetTarget(c95772051.thtg)
	e2:SetOperation(c95772051.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的光属性通常怪兽，且可以作为代价送去墓地，并考虑怪兽区域空格限制
function c95772051.spfilter(c,ft)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_NORMAL) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- 特殊召唤效果的启动代价：将自己场上1只表侧表示的光属性通常怪兽送去墓地
function c95772051.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价检查：检查怪兽区域是否有空位（若送墓的怪兽在主要怪兽区则空位要求可放宽），且场上是否存在至少1只满足过滤条件的光属性通常怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c95772051.spfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足过滤条件的光属性通常怪兽
	local g=Duel.SelectMatchingCard(tp,c95772051.spfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤效果的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c95772051.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将自身特殊召唤到场上
function c95772051.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到发动效果玩家的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：卡组中名字带有「圣剑」且可以加入手牌的卡
function c95772051.thfilter(c)
	return c:IsSetCard(0x207a) and c:IsAbleToHand()
end
-- 检索效果的启动代价：解放自己场上1只名字带有「圣骑士」的怪兽
function c95772051.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查自己场上是否存在至少1只可以解放的名字带有「圣骑士」的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x107a) end
	-- 让玩家选择1只自己场上名字带有「圣骑士」的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x107a)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 检索效果的发动准备：检查卡组中是否存在可检索的「圣剑」卡，并设置加入手牌的操作信息
function c95772051.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：检查卡组中是否存在至少1张满足过滤条件的「圣剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c95772051.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息，表示此效果会从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行：从卡组选择1张「圣剑」卡加入手牌并给对方确认
function c95772051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「圣剑」卡
	local g=Duel.SelectMatchingCard(tp,c95772051.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
