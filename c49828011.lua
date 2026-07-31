--祭司 レヴァリー
-- 效果：
-- 这张卡在手卡存在的场合：可以把1张其他手卡丢弃；这张卡特殊召唤。
-- 这张卡在自己墓地存在的状态，超量怪兽被送去墓地的场合（伤害步骤除外）：可以把这张卡除外；从自己墓地把1只不死族怪兽特殊召唤。
-- 这张卡被除外的下个回合的准备阶段：可以以自己场上1只不死族超量怪兽为对象；除外状态的这张卡在那只怪兽下面重叠作为超量素材。
-- 「尸会的空想」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建三个效果，分别对应手牌特殊召唤、墓地特殊召唤和除外状态重叠作为超量素材的效果
function s.initial_effect(c)
	-- 这张卡在手卡存在的场合：可以把1张其他手卡丢弃；这张卡特殊召唤。
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
	-- 这张卡在自己墓地存在的状态，超量怪兽被送去墓地的场合（伤害步骤除外）：可以把这张卡除外；从自己墓地把1只不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	-- 将此卡除外作为发动cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 这张卡被除外的下个回合的准备阶段：可以以自己场上1只不死族超量怪兽为对象；除外状态的这张卡在那只怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"作为超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.mtcon)
	e3:SetTarget(s.mttg)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断卡是否可丢弃
function s.dcfilter(c)
	return c:IsDiscardable()
end
-- 效果发动时的费用处理，丢弃一张手牌
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的手牌可以丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃操作
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 设置特殊召唤的目标和条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位以及此卡是否可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，告知对方此卡将被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，判断是否为超量怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ)
end
-- 判断是否满足墓地特殊召唤条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数，判断是否为不死族怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置墓地特殊召唤的目标和条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足条件的不死族怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
		-- 检查场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁信息，告知对方将从墓地特殊召唤不死族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行墓地特殊召唤操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的不死族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为除外后的下个准备阶段
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否为除外后的下一个回合的准备阶段
	return Duel.GetTurnCount()-c:GetTurnID()==1
end
-- 过滤函数，判断是否为不死族超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
-- 设置重叠作为超量素材的目标和条件
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.matfilter(chkc) end
	-- 检查场上是否存在满足条件的不死族超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的不死族超量怪兽作为对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行将此卡叠放于目标怪兽下的操作
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 将此卡叠放于目标怪兽下
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
