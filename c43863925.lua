--エクソシスター・ステラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只「救祓少女」怪兽特殊召唤。那之后，自己场上有「救祓少女·埃莉丝」存在的场合，自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c43863925.initial_effect(c)
	-- 将卡名中提到的「救祓少女·埃莉丝」（16474916）加入本卡的代码列表，用于记录该卡记载着此卡名。
	aux.AddCodeList(c,16474916)
	-- ①：自己主要阶段才能发动。从手卡把1只「救祓少女」怪兽特殊召唤。那之后，自己场上有「救祓少女·埃莉丝」存在的场合，自己回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43863925,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,43863925)
	e1:SetTarget(c43863925.efftg)
	e1:SetOperation(c43863925.effop)
	c:RegisterEffect(e1)
	-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43863925,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,43863926)
	e2:SetCondition(c43863925.spcon)
	e2:SetTarget(c43863925.sptg)
	e2:SetOperation(c43863925.spop)
	c:RegisterEffect(e2)
end
-- 特效特殊召唤的过滤器：判定手卡中的怪兽是否属于「救祓少女」系列，并且是否能够被效果特殊召唤。
function c43863925.effspfilter(c,e,tp)
	return c:IsSetCard(0x172) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件检测：自己场上主要怪兽区有空位，且手卡存在至少1只可被特殊召唤的「救祓少女」怪兽。
function c43863925.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件之一：自己场上（主要怪兽区）存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件之二：手牌中存在至少1张满足effspfilter过滤条件的「救祓少女」怪兽。
		and Duel.IsExistingMatchingCard(c43863925.effspfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，标明本效果涉及从手卡特殊召唤1只怪兽，供连锁检测和相关卡效果判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 辅助过滤器：检测场上是否存在表侧表示的「救祓少女·埃莉丝」（16474916）。
function c43863925.cfilter(c)
	return c:IsFaceup() and c:IsCode(16474916)
end
-- ①效果处理：选择手卡1只「救祓少女」怪兽特殊召唤；若特殊召唤成功且自己场上有「救祓少女·埃莉丝」，则中断连锁后回复800LP。
function c43863925.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认我方主要怪兽区仍有空位，若已无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选卡提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方手卡选择1张满足effspfilter条件的「救祓少女」怪兽。
	local g=Duel.SelectMatchingCard(tp,c43863925.effspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 如果选择成功并且该怪兽被特殊召唤成功，则继续后续判定。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判定特殊召唤后，我方场上是否表侧表示存在「救祓少女·埃莉丝」（16474916）。
		and Duel.IsExistingMatchingCard(c43863925.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续回复LP不被视为与特殊召唤同一时点的处理，避免错失时点。
		Duel.BreakEffect()
		-- 我方回复800基本分，回复原因为效果。
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- ②效果的发动条件：触发者rp为我方对手（rp==1-tp），即对方让我方或对方的卡从墓地离开。
function c43863925.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 额外卡组特殊召唤的过滤器：选择「救祓少女」超量怪兽，该怪兽能够以这张卡（斯特拉）为超量素材，并且能够以超量召唤方式从额外卡组特殊召唤，且场上有可用的额外怪兽区空格。
function c43863925.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 该超量怪兽可以这张卡作为超量素材，且特殊召唤所需的额外卡组怪兽区域空格足够。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的发动目标检测：确认这张卡仍可作为超量素材，且额外卡组存在符合条件的「救祓少女」超量怪兽。
function c43863925.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测这张卡是否可作为超量素材，即未受到“必须成为超量素材”以外的素材限制。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 额外卡组中存在至少1只满足spfilter过滤条件的「救祓少女」超量怪兽。
		and Duel.IsExistingMatchingCard(c43863925.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息，标明本效果涉及从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：以这张卡作为超量素材，将额外卡组1只「救祓少女」超量怪兽叠放在这张卡上面，当作超量召唤进行特殊召唤。
function c43863925.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认这张卡仍可作为超量素材，否则终止处理。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 弹出选卡提示，让玩家选择要特殊召唤的额外卡组怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足spfilter条件的「救祓少女」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c43863925.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 如果这张卡（斯特拉）原本持有超量素材，先把这些素材全部转移给要特殊召唤的超量怪兽。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡（斯特拉）自身作为超量素材叠放在超量怪兽下面。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 以超量召唤的方式将选中的「救祓少女」超量怪兽特殊召唤到我方场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
