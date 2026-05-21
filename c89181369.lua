--星屑のきらめき
-- 效果：
-- 选择自己墓地存在的1只龙族的同调怪兽发动。直到变成和那只怪兽的等级相同等级为止，把选择的怪兽以外的自己墓地存在的怪兽从游戏中除外，选择的怪兽从墓地特殊召唤。
function c89181369.initial_effect(c)
	-- 选择自己墓地存在的1只龙族的同调怪兽发动。直到变成和那只怪兽的等级相同等级为止，把选择的怪兽以外的自己墓地存在的怪兽从游戏中除外，选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89181369.target)
	e1:SetOperation(c89181369.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查墓地中的龙族同调怪兽是否可以特殊召唤，且墓地中存在其他等级合计等于该怪兽等级的除外素材
function c89181369.spfilter(c,e,tp,rg)
	if not c:IsType(TYPE_SYNCHRO) or not c:IsRace(RACE_DRAGON) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	local result=false
	if rg:IsContains(c) then
		rg:RemoveCard(c)
		result=rg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
		rg:AddCard(c)
	else
		result=rg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
	end
	return result
end
-- 过滤函数：用于筛选墓地中等级大于0且可以除外的怪兽
function c89181369.rmfilter(c)
	return c:GetLevel()>0 and c:IsAbleToRemove()
end
-- 效果发动时的处理：检查发动条件，选择墓地中1只龙族同调怪兽作为对象，并设置特殊召唤的操作信息
function c89181369.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 检查自己场上的主要怪兽区域是否有空位，若无空位则不能发动
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 获取自己墓地中所有可以被除外的怪兽
		local rg=Duel.GetMatchingGroup(c89181369.rmfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查自己墓地中是否存在可以作为效果对象的、满足特殊召唤条件的龙族同调怪兽
		return Duel.IsExistingTarget(c89181369.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,rg)
	end
	-- 获取自己墓地中所有可以被除外的怪兽
	local rg=Duel.GetMatchingGroup(c89181369.rmfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置选择卡片时的提示信息为：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的龙族同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89181369.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,rg)
	-- 设置当前连锁的操作信息，表明此效果包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取对象怪兽，并检查其是否仍满足特殊召唤条件以及场上是否有空位
function c89181369.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍对该效果有效，以及自己场上是否有可用的怪兽区域空格
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 获取自己墓地中所有可以被除外的怪兽
	local rg=Duel.GetMatchingGroup(c89181369.rmfilter,tp,LOCATION_GRAVE,0,nil)
	rg:RemoveCard(tc)
	if rg:CheckWithSumEqual(Card.GetLevel,tc:GetLevel(),1,99) then
		-- 设置选择卡片时的提示信息为：请选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rm=rg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,99)
		-- 将选中的素材怪兽以表侧表示除外
		Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
		-- 将作为对象的龙族同调怪兽从墓地表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
