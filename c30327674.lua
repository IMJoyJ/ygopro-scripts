--カオス・ウィッチ－混沌の魔女－
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，发动的回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
-- ①：把这张卡解放才能发动。在自己场上把2只「黑兽衍生物」（恶魔族·暗·2星·攻1000/守500）特殊召唤。
-- ②：这张卡从手卡·墓地除外的场合才能发动。在自己场上把2只「白兽衍生物」（天使族·调整·光·2星·攻500/守1000）特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①为起动效果，②为除外时效果
function s.initial_effect(c)
	-- ①：把这张卡解放才能发动。在自己场上把2只「黑兽衍生物」（恶魔族·暗·2星·攻1000/守500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·墓地除外的场合才能发动。在自己场上把2只「白兽衍生物」（天使族·调整·光·2星·攻500/守1000）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于限制每回合只能发动一次效果
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，用于判断是否满足发动条件
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
		or (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- ①效果的费用处理，检查是否可以解放此卡并满足发动条件
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以解放此卡
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>1
		-- 检查是否为本回合第一次发动效果
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 将此卡解放作为费用
	Duel.Release(c,REASON_COST)
	-- ①效果发动后，禁止在本回合从额外卡组特殊召唤非光·暗属性的同调怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 禁止特殊召唤的过滤函数，仅禁止非光·暗属性的同调怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- ①效果的发动条件检测，检查是否可以特殊召唤衍生物
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查是否可以特殊召唤黑兽衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息，表示将特殊召唤2只黑兽衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将特殊召唤2只黑兽衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果的处理，特殊召唤2只黑兽衍生物
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有足够的怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查是否可以特殊召唤黑兽衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 创建黑兽衍生物
			local token=Duel.CreateToken(tp,id+o)
			-- 将黑兽衍生物特殊召唤
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的发动条件，检查此卡是否从手卡或墓地除外
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的费用处理，检查是否为本回合第一次发动效果
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次发动效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ②效果发动后，禁止在本回合从额外卡组特殊召唤非光·暗属性的同调怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册禁止特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件检测，检查是否可以特殊召唤衍生物
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有足够的怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查是否可以特殊召唤白兽衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o*2,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,500,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置操作信息，表示将特殊召唤2只白兽衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息，表示将特殊召唤2只白兽衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②效果的处理，特殊召唤2只白兽衍生物
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有足够的怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查是否可以特殊召唤白兽衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o*2,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,500,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		for i=1,2 do
			-- 创建白兽衍生物
			local token=Duel.CreateToken(tp,id+o*2)
			-- 将白兽衍生物特殊召唤
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
