--エクソシスター・マルファ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有超量怪兽的场合才能发动（这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。这张卡从手卡特殊召唤，从卡组把1只「救祓少女·埃莉丝」特殊召唤。
-- ②：自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c37343995.initial_effect(c)
	-- 在卡组提示/关联卡片中注册「救祓少女·埃莉丝」的卡片密码
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
	-- 注册特殊召唤「救祓少女」怪兽的自定义活动计数器
	Duel.AddCustomActivityCounter(37343995,ACTIVITY_SPSUMMON,c37343995.counterfilter)
end
-- 过滤条件，检查特殊召唤的是否为表侧表示的「救祓少女」怪兽
function c37343995.counterfilter(c)
	return c:IsSetCard(0x172) and c:IsFaceup()
end
-- 过滤条件，检查自己场上的怪兽是否为表侧表示的超量怪兽
function c37343995.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果①的发动条件：自己场上没有怪兽或者仅有超量怪兽
function c37343995.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 判断自己场上是否没有怪兽，或者场上的怪兽数量等于表侧表示超量怪兽的数量
	return ct==0 or ct==Duel.GetMatchingGroupCount(c37343995.cfilter,tp,LOCATION_MZONE,0,nil)
end
-- 效果①的发动代价：确认本回合未特殊召唤过「救祓少女」以外的怪兽，并限制本回合不能特殊召唤「救祓少女」以外的怪兽
function c37343995.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断本回合玩家是否没有特殊召唤过「救祓少女」以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(37343995,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的怪兽不存在的场合或者只有超量怪兽的场合才能发动（这个效果发动的回合，自己不是「救祓少女」怪兽不能特殊召唤）。这张卡从手卡特殊召唤，从卡组把1只「救祓少女·埃莉丝」特殊召唤。②：自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c37343995.splimit)
	-- 为玩家注册本回合不能特殊召唤「救祓少女」以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽必须是「救祓少女」怪兽
function c37343995.splimit(e,c)
	return not c:IsSetCard(0x172)
end
-- 过滤条件，检查卡片是否为可以特殊召唤的「救祓少女·埃莉丝」
function c37343995.spfilter(c,e,tp)
	return c:IsCode(16474916) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检查：检查是否不受「青眼精灵龙」影响、自己场上是否有2个以上空怪兽区域、手牌的这张卡与卡组的「救祓少女·埃莉丝」是否可以特殊召唤
function c37343995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断自己场上的怪兽区域是否有2个以上的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断卡组中是否存在可以特殊召唤的「救祓少女·埃莉丝」
		and Duel.IsExistingMatchingCard(c37343995.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，准备特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将手卡的这张卡特殊召唤，并从卡组把1只「救祓少女·埃莉丝」特殊召唤
function c37343995.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只可以特殊召唤的「救祓少女·埃莉丝」
		local g=Duel.SelectMatchingCard(tp,c37343995.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 对选择的「救祓少女·埃莉丝」进行特殊召唤的分解步骤
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 完成所有分解步骤中的特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 过滤条件，检查额外卡组中的「救祓少女」超量怪兽是否能够以本卡为素材进行超量召唤
function c37343995.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 判断该怪兽是否能进行超量特殊召唤，以及是否有可用的额外怪兽区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动检查：检测超量素材限制以及额外卡组中是否有符合条件的「救祓少女」超量怪兽
function c37343995.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断本卡是否满足作为超量素材的必须素材检测
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组中是否存在符合条件的「救祓少女」超量怪兽
		and Duel.IsExistingMatchingCard(c37343995.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置效果处理信息，准备从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：将额外卡组中的「救祓少女」超量怪兽在自己场上的本卡上面重叠当作超量召唤特殊召唤
function c37343995.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断本卡是否满足作为超量素材的必须素材检测，若不满足则结束处理
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只满足条件的「救祓少女」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c37343995.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将本卡原本持有的超量素材移到新超量怪兽下方作为超量素材
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将本卡叠放到新超量怪兽下方作为超量素材
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将该超量怪兽表侧表示特殊召唤（当作超量召唤）
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
