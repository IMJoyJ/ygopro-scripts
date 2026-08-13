--分裂するマザー・スパイダー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从手卡·卡组把最多3只「小蜘蛛」特殊召唤。这个效果特殊召唤的怪兽等级变成5星，作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
function c34034150.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34034150.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡解放才能发动。从手卡·卡组把最多3只「小蜘蛛」特殊召唤。这个效果特殊召唤的怪兽等级变成5星，作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34034150,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34034150)
	e2:SetCost(c34034150.spcost)
	e2:SetTarget(c34034150.sptg)
	e2:SetOperation(c34034150.spop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判定：若c为nil则表示查询可否进行该规则特殊召唤并返回true；否则要求这张卡的控制者场上没有怪兽且主怪兽区有空位。
function c34034150.sprcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者（我方）怪兽区没有怪兽，即满足“自己场上没有怪兽存在”的条件。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 同时确认我方主怪兽区存在空位，可以放置特殊召唤的怪兽。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ②效果的发动代价：解放这张卡。代价检测时确认此卡可被解放且解放后仍有空余怪兽区；实际发动时执行解放。
function c34034150.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检测：返回此卡是否可解放，以及解放后我方是否有可用的怪兽区空格。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 以规则代价（REASON_COST）解放这张卡。
	Duel.Release(c,REASON_COST)
end
-- 筛选函数：卡名必须是「小蜘蛛」（60023855），且能够被当前效果正常特殊召唤（满足召唤条件和苏生限制）。
function c34034150.spfilter(c,e,tp)
	return c:IsCode(60023855) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标：确认手卡·卡组存在至少1只「小蜘蛛」可特召，并登记操作信息（特殊召唤，来源为手卡·卡组）。
function c34034150.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：检查手卡·卡组是否存在至少1只符合筛选条件的「小蜘蛛」。
	if chk==0 then return Duel.IsExistingMatchingCard(c34034150.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本效果将进行特殊召唤，预计数量为1（实际可变），来源为手卡·卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：先给自己附加本回合不能从额外卡组特召非超量怪兽的限制；计算可特召数量（上限3且不超过怪兽区空格，若对方场上有青眼精灵龙则只能1只）；从手卡·卡组选择「小蜘蛛」并逐只特殊召唤，同时附加等级变为5星和超量素材限制。
function c34034150.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从手卡·卡组把最多3只「小蜘蛛」特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34034150.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该限制效果注册到玩家tp，效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 获取tp可用的怪兽区数量，用于限制本次特殊召唤的数量。
	local ft=Duel.GetMZoneCount(tp)
	-- 取得手卡·卡组中所有满足条件的「小蜘蛛」的集合。
	local g=Duel.GetMatchingGroup(c34034150.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or #g==0 then return end
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,ft,nil)
	-- 遍历选中的每张「小蜘蛛」，执行后续处理。
	for tc in aux.Next(sg) do
		-- 将当前「小蜘蛛」以表侧表示特殊召唤到tp场上（作为特殊召唤过程中的一步）。nocheck=false/nolimit=false表示仍需检查召唤条件和苏生限制。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽等级变成5星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetValue(c34034150.xyzlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤步骤，整个特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
-- 限制判定：额外卡组的非超量怪兽不能特殊召唤，即本回合从额外卡组只能特殊召唤超量怪兽。
function c34034150.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 超量素材判定：若作为超量素材的怪兽不是暗属性，则不能进行超量召唤；即被赋予此效果的「小蜘蛛」只能用于暗属性超量召唤。
function c34034150.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
