--エクソシスター・エリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「救祓少女」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有「救祓少女·斯特拉」存在的场合，再让自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c16474916.initial_effect(c)
	-- 记录该卡与「救祓少女·斯特拉」的关联
	aux.AddCodeList(c,43863925)
	-- ①：自己场上有「救祓少女」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有「救祓少女·斯特拉」存在的场合，再让自己回复800基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16474916,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,16474916)
	e1:SetCondition(c16474916.effcon)
	e1:SetTarget(c16474916.efftg)
	e1:SetOperation(c16474916.effop)
	c:RegisterEffect(e1)
	-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16474916,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,16474917)
	e2:SetCondition(c16474916.spcon)
	e2:SetTarget(c16474916.sptg)
	e2:SetOperation(c16474916.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否有「救祓少女」怪兽（正面表示）
function c16474916.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 效果①的发动条件：自己场上有「救祓少女」怪兽（正面表示）
function c16474916.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「救祓少女」怪兽（正面表示）
	return Duel.IsExistingMatchingCard(c16474916.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时的处理：判断是否满足特殊召唤条件
function c16474916.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息：将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于判断场上是否有「救祓少女·斯特拉」（正面表示）
function c16474916.cfilter1(c)
	return c:IsFaceup() and c:IsCode(43863925)
end
-- 效果①的发动处理：将该卡特殊召唤，并在满足条件时回复LP
function c16474916.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在「救祓少女·斯特拉」
		and Duel.IsExistingMatchingCard(c16474916.cfilter1,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 使自己回复800基本分
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方让自己或对方的卡从墓地离开
function c16474916.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤函数，用于选择满足条件的「救祓少女」超量怪兽
function c16474916.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 判断该超量怪兽是否可以被特殊召唤并满足召唤条件
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动时的处理：判断是否满足特殊召唤条件
function c16474916.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查该卡是否必须作为超量素材
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查自己额外卡组是否存在满足条件的「救祓少女」超量怪兽
		and Duel.IsExistingMatchingCard(c16474916.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置效果②的处理信息：将1只超量怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的发动处理：选择并特殊召唤1只超量怪兽
function c16474916.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否必须作为超量素材
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只满足条件的超量怪兽
		local g=Duel.SelectMatchingCard(tp,c16474916.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将该卡的叠放卡叠放到目标超量怪兽上
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将该卡叠放到目标超量怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将目标超量怪兽特殊召唤
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
