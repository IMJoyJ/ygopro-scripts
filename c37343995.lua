--エクソシスター・マルファ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有超量怪兽的场合才能发动（这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。这张卡从手卡特殊召唤，从卡组把1只「救祓少女·埃莉丝」特殊召唤。
-- ②：自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c37343995.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「救祓少女·埃莉丝」。
	aux.AddCodeList(c,16474916)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的怪兽不存在的场合或者只有超量怪兽的场合才能发动（这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。这张卡从手卡特殊召唤，从卡组把1只「救祓少女·埃莉丝」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37343995,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37343995)
	e1:SetCondition(c37343995.spcon)
	e1:SetCost(c37343995.spcost)
	e1:SetTarget(c37343995.sptg)
	e1:SetOperation(c37343995.spop)
	c:RegisterEffect(e1)
	-- ②：自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37343995,1))  --"当作超量召唤从额外卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37343996)
	e2:SetTarget(c37343995.xyztg)
	e2:SetOperation(c37343995.xyzop)
	c:RegisterEffect(e2)
	-- 注册自定义特殊召唤活动计数器，用于监控自己本回合是否特殊召唤过非「救祓少女」怪兽。
	Duel.AddCustomActivityCounter(37343995,ACTIVITY_SPSUMMON,c37343995.counterfilter)
end
-- 计数器过滤函数：返回表侧表示的「救祓少女」怪兽，用于排除不触发誓约限制的召唤。
function c37343995.counterfilter(c)
	return c:IsSetCard(0x172) and c:IsFaceup()
end
-- 过滤条件：检查怪兽是否为表侧表示的超量怪兽。
function c37343995.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ①效果的发动条件：检查自己场上怪兽数量为0或全部为表侧表示超量怪兽。
function c37343995.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己怪兽区当前存在的怪兽总数。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 判断自己场上是否没有怪兽，或者场上怪兽总数等于表侧超量怪兽数量。
	return ct==0 or ct==Duel.GetMatchingGroupCount(c37343995.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- ①效果的发动代价：检查本回合未特招非「救祓少女」怪兽，并注册持续到回合结束的特招自肃。
function c37343995.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认本回合己方尚未特殊召唤过「救祓少女」以外的怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(37343995,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c37343995.splimit)
	-- 为己方玩家注册持续至回合结束的特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制目标函数：限制不能特殊召唤「救祓少女」字段以外的怪兽。
function c37343995.splimit(e,c)
	return not c:IsSetCard(0x172)
end
-- 过滤条件：检查卡片是否为可特殊召唤的「救祓少女·埃莉丝」。
function c37343995.spfilter(c,e,tp)
	return c:IsCode(16474916) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数：检查青眼精灵龙限制、2个怪兽区空位及自身与卡组「救祓少女·埃莉丝」的特招条件。
function c37343995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区是否有至少2个空位以同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己卡组存在至少1只可特殊召唤的「救祓少女·埃莉丝」。
		and Duel.IsExistingMatchingCard(c37343995.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：预计将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：分步特殊召唤手卡的这张卡与卡组的1只「救祓少女·埃莉丝」，并统一完成特殊召唤。
function c37343995.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己卡组选择1只「救祓少女·埃莉丝」。
		local g=Duel.SelectMatchingCard(tp,c37343995.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 分步将卡组选中的「救祓少女·埃莉丝」以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 结算分步特殊召唤流程，统一触发召唤成功时点。
	Duel.SpecialSummonComplete()
end
-- 过滤条件：检查额外卡组中的卡是否为可以这张卡作为超量素材、且可超量召唤到可用额外怪兽区空位的「救祓少女」超量怪兽。
function c37343995.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该超量怪兽是否可以被超量召唤，且在把这张卡叠放后仍有可用的额外怪兽召唤空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的目标处理函数：检查必须成为超量素材限制及额外卡组是否存在可超量召唤的「救祓少女」超量怪兽。
function c37343995.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：确认当前没有受到阻止这张卡成为超量素材的限制效果影响。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认额外卡组存在至少1只可重叠在这张卡上面进行超量召唤的「救祓少女」超量怪兽。
		and Duel.IsExistingMatchingCard(c37343995.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：预计从自己额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数：确认条件后从额外卡组选择1只「救祓少女」超量怪兽，将这张卡及其原有素材叠放在下面并当作超量召唤特殊召唤。
function c37343995.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次检查必须成为超量素材的限制条件，不满足则结束处理。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己额外卡组选择1只可重叠超量召唤的「救祓少女」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c37343995.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 若这张卡原本持有超量素材，将这些超量素材转移到新超量怪兽下面。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡本身作为超量素材重叠到所选超量怪兽下面。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将所选「救祓少女」超量怪兽当作超量召唤以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
