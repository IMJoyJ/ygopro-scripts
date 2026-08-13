--カオス・ウィッチ－混沌の魔女－
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，发动的回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。
-- ①：把这张卡解放才能发动。在自己场上把2只「黑兽衍生物」（恶魔族·暗·2星·攻1000/守500）特殊召唤。
-- ②：这张卡从手卡·墓地除外的场合才能发动。在自己场上把2只「白兽衍生物」（天使族·调整·光·2星·攻500/守1000）特殊召唤。
local s,id,o=GetID()
-- 初始化函数：创建并注册①起动效果（解放自身特殊召唤2只黑兽衍生物）和②诱发效果（从手卡·墓地除外时特殊召唤2只白兽衍生物），并添加本回合特殊召唤自肃用的活动计数器。
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
	-- 为特殊召唤操作添加自定义活动计数器，用于限制发动的回合内不能进行“从额外卡组特殊召唤非光/暗属性同调怪兽”。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 定义计数器过滤函数：若怪兽不是从额外卡组特殊召唤，或者是从额外卡组的「光/暗属性同调怪兽」，则允许（不计数）；否则返回false，使计数器累积违规特殊召唤。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
		or (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- ①效果的代价检查：这张卡可以解放、解放后我方怪兽区至少还有2个可用区域，且本回合尚未进行过被自肃限制的特殊召唤。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查阶段：确认这张卡可以解放，且解放后我方怪兽区至少还有2个空格，用于放置2只衍生物。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>1
		-- 同时确认本回合自定义活动计数为0，即尚未进行过“非光/暗同调怪兽的额外特殊召唤”，满足发动自肃。
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 将此卡解放作为发动①效果的代价。
	Duel.Release(c,REASON_COST)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，发动的回合，自己不是光·暗属性的同调怪兽不能从额外卡组特殊召唤。①：把这张卡解放才能发动。在自己场上把2只「黑兽衍生物」（恶魔族·暗·2星·攻1000/守500）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将创建的“不能从额外卡组特殊召唤非光/暗属性同调怪兽”的誓约效果注册给当前玩家，在回合结束前适用。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃过滤条件：若特殊召唤的怪兽来自额外卡组，且不是光/暗属性同调怪兽，则禁止特殊召唤。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK))
end
-- ①效果的发动条件检测：确认当前不受「青眼精灵龙」的“不能同时特殊召唤2只以上怪兽”效果影响，且玩家可以特殊召唤2只黑兽衍生物。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 额外确认玩家可以特殊召唤满足指定参数（恶魔族·暗·2星·攻1000/守500）的黑兽衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：本次效果将涉及2只衍生物的生成，类别为TOKEN。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果将特殊召唤2只怪兽，类别为SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果处理：若仍不受「青眼精灵龙」影响、场上空位足够且可特招黑兽衍生物，则生成2只黑兽衍生物并特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方怪兽区至少还有2个可用空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认玩家可以特殊召唤黑兽衍生物，满足条件后进入生成步骤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,1000,500,2,RACE_FIEND,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 创建1只黑兽衍生物（卡号id+o，对应黑兽衍生物）。
			local token=Duel.CreateToken(tp,id+o)
			-- 将黑兽衍生物以表侧表示加入连续特殊召唤处理步骤。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 结束连续特殊召唤处理，实际完成所有衍生物的特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的触发条件：这张卡从手卡或墓地除外时才能发动，判定其除外前所在位置为手卡或墓地。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的代价函数：确认本回合尚未进行过被自肃限制的特殊召唤，并注册“不能从额外卡组特殊召唤非光/暗同调怪兽”的誓约效果。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认本回合自定义活动计数为0，即尚未进行过违规的额外卡组特殊召唤。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- ②：这张卡从手卡·墓地除外的场合才能发动。在自己场上把2只「白兽衍生物」（天使族·调整·光·2星·攻500/守1000）特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将自肃效果注册给当前玩家，使该限制在回合结束前生效。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件检测：不受「青眼精灵龙」影响、我方怪兽区至少2个空位、且可以特殊召唤白兽衍生物。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方怪兽区至少还有2个可用空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认玩家可以特殊召唤白兽衍生物（天使族·调整·光·2星·攻500/守1000）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o*2,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,500,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：本次效果将生成2只衍生物，类别为TOKEN。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果将特殊召唤2只怪兽，类别为SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ②效果处理：若条件仍满足，则生成2只白兽衍生物并特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方怪兽区至少还有2个可用空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认玩家可以特殊召唤白兽衍生物，满足条件后进入生成步骤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o*2,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,500,1000,2,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		for i=1,2 do
			-- 创建1只白兽衍生物（卡号id+o*2，对应白兽衍生物）。
			local token=Duel.CreateToken(tp,id+o*2)
			-- 将白兽衍生物以表侧表示加入连续特殊召唤处理步骤。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 结束连续特殊召唤处理，实际完成所有衍生物的特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
