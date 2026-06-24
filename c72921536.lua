--コミックキャット
local s,id,o=GetID()
-- 初始化效果，注册两个效果，第一个为将自身变为卡通怪兽类型的效果，第二个为发动时可以解放场上一张卡并特殊召唤手牌或卡组中一张记载着15259703的怪兽的效果
function s.initial_effect(c)
	-- 记录该卡上记载着15259703这张卡名
	aux.AddCodeList(c,15259703)
	-- 这张卡在场上表侧表示存在时，自身变成卡通怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.addcon)
	e1:SetValue(TYPE_TOON)
	c:RegisterEffect(e1)
	-- 场上的这张卡在主要阶段可以发动。把场上1只怪兽解放，从手卡或卡组把1只记载着15259703的怪兽特殊召唤。
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
-- 过滤函数，用于判断场上是否存在一张表侧表示且卡号为15259703的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果条件函数，判断是否满足将自身变为卡通怪兽类型的条件，即场上有1张以上表侧表示的15259703
function s.addcon(e)
	-- 检查场上是否存在至少1张表侧表示的15259703
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 发动条件函数，判断是否处于主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤函数，用于判断是否可以被解放且满足特殊召唤条件的怪兽
function s.cfilter2(c,tp,skip)
	-- 判断该怪兽是否可以被效果解放，并且如果skip为假则还需满足有可用怪兽区
	return c:IsReleasableByEffect() and (skip or Duel.GetMZoneCount(tp,c)>0)
end
-- 过滤函数，用于判断手牌或卡组中是否存在可以特殊召唤的记载着15259703的怪兽
function s.spfilter(c,e,tp)
	-- 判断该怪兽是否记载着15259703且为怪兽类型并可被特殊召唤
	return aux.IsCodeListed(c,15259703) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的处理函数，设置发动时需要处理的卡组信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	-- 判断场上是否存在至少1张表侧表示的15259703
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		loc=LOCATION_MZONE
	end
	-- 检查是否满足解放条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,loc,1,nil,tp,false)
		-- 检查是否满足特殊召唤条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,false) end
	-- 设置操作信息：将要解放的卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤的卡数量为1，来源为手牌或卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果发动时的具体处理函数，执行解放和特殊召唤的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	-- 判断场上是否存在至少1张表侧表示的15259703
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		loc=LOCATION_MZONE
	end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg
	-- 检查是否满足解放条件
	if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,loc,1,nil,tp,false) then
		-- 选择一张可以被解放的怪兽
		rg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,loc,1,1,nil,tp,false)
	else
		-- 选择一张可以被解放的怪兽（跳过怪兽区限制）
		rg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE,loc,1,1,nil,tp,true)
	end
	-- 判断所选怪兽数量大于0且成功解放
	if rg:GetCount()>0 and Duel.Release(rg,REASON_EFFECT)>0
		-- 判断是否有可用怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择一张可以特殊召唤的怪兽
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
