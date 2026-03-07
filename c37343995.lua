--エクソシスター・マルファ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有超量怪兽的场合才能发动（这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。这张卡从手卡特殊召唤，从卡组把1只「救祓少女·埃莉丝」特殊召唤。
-- ②：自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c37343995.initial_effect(c)
	-- 记录该卡牌具有「救祓少女·埃莉丝」的卡名信息
	aux.AddCodeList(c,16474916)
	-- ①：自己场上的怪兽不存在的场合或者只有超量怪兽的场合才能发动（这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。这张卡从手卡特殊召唤，从卡组把1只「救祓少女·埃莉丝」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37343995,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
	-- 设置一个计数器，用于记录该卡在本回合中特殊召唤的次数
	Duel.AddCustomActivityCounter(37343995,ACTIVITY_SPSUMMON,c37343995.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「救祓少女」系列
function c37343995.counterfilter(c)
	return c:IsSetCard(0x172)
end
-- 过滤函数，判断场上是否有表侧表示的超量怪兽
function c37343995.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果条件函数，判断自己场上是否没有怪兽或只有超量怪兽
function c37343995.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 判断自己场上怪兽数量为0或等于场上超量怪兽数量
	return ct==0 or ct==Duel.GetMatchingGroupCount(c37343995.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- 效果费用函数，检查本回合是否已使用过此效果
function c37343995.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合中是否已进行过特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(37343995,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个禁止特殊召唤的效果，仅限本回合有效
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c37343995.splimit)
	-- 将创建的效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止召唤非「救祓少女」系列的怪兽
function c37343995.splimit(e,c)
	return not c:IsSetCard(0x172)
end
-- 过滤函数，用于检索卡组中「救祓少女·埃莉丝」
function c37343995.spfilter(c,e,tp)
	return c:IsCode(16474916) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标函数，判断是否满足特殊召唤条件
function c37343995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断自己场上是否有足够的召唤空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断卡组中是否存在「救祓少女·埃莉丝」
		and Duel.IsExistingMatchingCard(c37343995.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，表示将特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c37343995.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择「救祓少女·埃莉丝」
		local g=Duel.SelectMatchingCard(tp,c37343995.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「救祓少女·埃莉丝」特殊召唤
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 超量召唤过滤函数，判断是否可以作为超量素材并特殊召唤
function c37343995.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 判断该超量怪兽是否可以特殊召唤且有足够召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 超量召唤目标函数，判断是否满足发动条件
function c37343995.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查该卡是否满足作为超量素材的条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 判断额外卡组中是否存在符合条件的「救祓少女」超量怪兽
		and Duel.IsExistingMatchingCard(c37343995.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置效果处理时的操作信息，表示将特殊召唤一张超量怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 超量召唤处理函数，执行超量召唤操作
function c37343995.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择符合条件的超量怪兽
		local g=Duel.SelectMatchingCard(tp,c37343995.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将原卡的叠放卡叠放到新召唤的超量怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将原卡叠放到新召唤的超量怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将选中的超量怪兽以超量召唤方式特殊召唤
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
