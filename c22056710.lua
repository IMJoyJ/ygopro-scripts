--ヴァンパイアジェネシス
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「吸血鬼领主」从游戏中除外的场合才能特殊召唤。1回合1次，可以通过从手卡把1只不死族怪兽丢弃去墓地，从自己墓地选择1只比丢弃的不死族怪兽等级低的不死族怪兽特殊召唤。
function c22056710.initial_effect(c)
	-- 记录此卡具有「吸血鬼领主」这张卡的卡名
	aux.AddCodeList(c,53839837)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上存在的1只「吸血鬼领主」从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 特殊召唤规则：将场上1只「吸血鬼领主」除外才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c22056710.hspcon)
	e2:SetTarget(c22056710.hsptg)
	e2:SetOperation(c22056710.hspop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以通过从手卡把1只不死族怪兽丢弃去墓地，从自己墓地选择1只比丢弃的不死族怪兽等级低的不死族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22056710,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c22056710.sptg)
	e3:SetOperation(c22056710.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否存在可除外的「吸血鬼领主」
function c22056710.hspfilter(c,tp)
	-- 检查场上是否存在可除外的「吸血鬼领主」
	return c:IsCode(53839837) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤条件函数：检查场上是否存在可除外的「吸血鬼领主」
function c22056710.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在可除外的「吸血鬼领主」
	return Duel.IsExistingMatchingCard(c22056710.hspfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤目标选择函数：选择要除外的「吸血鬼领主」
function c22056710.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有可除外的「吸血鬼领主」
	local g=Duel.GetMatchingGroup(c22056710.hspfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作函数：将选择的卡除外
function c22056710.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 过滤函数：检查手牌中是否存在可丢弃的不死族怪兽
function c22056710.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
		-- 检查墓地中是否存在比丢弃的不死族怪兽等级低的不死族怪兽
		and Duel.IsExistingTarget(c22056710.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalLevel())
end
-- 过滤函数：检查墓地中是否存在可特殊召唤的不死族怪兽
function c22056710.spfilter(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and clv<lv and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤目标选择函数：检查是否满足发动条件
function c22056710.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否有足够的怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可丢弃的不死族怪兽
		and Duel.IsExistingMatchingCard(c22056710.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择要丢弃的手牌
	local g1=Duel.SelectMatchingCard(tp,c22056710.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的手牌送去墓地
	Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的不死族怪兽
	local g2=Duel.SelectTarget(tp,c22056710.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g1:GetFirst():GetOriginalLevel())
	-- 设置操作信息：准备特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 特殊召唤操作函数：将目标怪兽特殊召唤
function c22056710.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
