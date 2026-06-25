--コミックキャット
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（在场上有「卡通世界」存在时当作卡通怪兽使用，以及在双方主要阶段解放自己场上1只怪兽无视条件特殊召唤手牌·卡组记有「卡通世界」卡名的怪兽）
function s.initial_effect(c)
	-- 记录该卡片记有卡名「卡通世界」（卡号：15259703）的事实
	aux.AddCodeList(c,15259703)
	-- 只要场上有「卡通世界」存在，这张卡就当作卡通怪兽使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.addcon)
	e1:SetValue(TYPE_TOON)
	c:RegisterEffect(e1)
	-- 在自己·对方的主要阶段可以发动。将自己场上的1只怪兽解放，从手牌·牌组中将1只记有「卡通世界」卡名的怪兽无视召唤条件特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断卡片是否为表侧表示的「卡通世界」的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果①当作卡通怪兽使用的生效条件函数
function s.addcon(e)
	-- 检查场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果②在主要阶段发动的条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤自己场上可被效果解放且解放后能空出怪兽区域的怪兽的过滤函数
function s.cfilter2(c,tp,skip)
	-- 判断目标怪兽是否可以被效果解放，且在被解放后（若不跳过怪兽区检查）使怪兽区域空间大于0
	return c:IsReleasableByEffect() and (skip or Duel.GetMZoneCount(tp,c)>0)
end
-- 过滤手牌或卡组中记有「卡通世界」卡名且可以无视召唤条件特殊召唤的怪兽的过滤函数
function s.spfilter(c,e,tp)
	-- 检查卡片是否记有「卡通世界」卡名，是怪兽卡，且可以无视召唤条件特殊召唤
	return aux.IsCodeListed(c,15259703) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②特殊召唤效果的发动准备与检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	-- 检查自己场上是否存在表侧表示的「卡通世界」以决定解放怪兽的可选范围
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		loc=LOCATION_MZONE
	end
	-- 在chk==0时，检查场上是否有满足条件的怪兽可以被解放
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,loc,1,nil,tp,false)
		-- 并且检查手牌或卡组中是否存在可以特殊召唤的目标怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,false) end
	-- 设置效果处理的分类为解放，数量为1张卡
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置效果处理的分类为特殊召唤，数量为1，目标位置为手牌·卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	-- 检查自己场上是否存在表侧表示的「卡通世界」（用于确定是否可以解放对方场上的怪兽）
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		loc=LOCATION_MZONE
	end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg
	-- 检查在解放后能空出怪兽区域的情况下，场上是否存在可解放的怪兽
	if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,loc,1,nil,tp,false) then
		-- 让玩家选择1只解放后能空出怪兽区域的怪兽进行解放
		rg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,loc,1,1,nil,tp,false)
	else
		-- 让玩家在不检查空出怪兽区域限制的情况下，选择1只怪兽进行解放
		rg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,loc,1,1,nil,tp,true)
	end
	-- 如果选择了要解放的怪兽，并且成功将其解放
	if rg:GetCount()>0 and Duel.Release(rg,REASON_EFFECT)>0
		-- 并且检查自己场上的怪兽区域是否有可用的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择手牌或卡组中1只满足特殊召唤条件的目标怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选择的怪兽以表侧表示无视召唤条件特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
