--エクソシスター・エリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「救祓少女」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有「救祓少女·斯特拉」存在的场合，再让自己回复800基本分。
-- ②：对方让自己或对方的卡从墓地离开的场合才能发动。把1只「救祓少女」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。
function c16474916.initial_effect(c)
	-- 将卡号43863925（「救祓少女·斯特拉」）登记为本卡记载的卡名，使本卡在规则上也能视为或关联该卡名。
	aux.AddCodeList(c,43863925)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「救祓少女」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。自己场上有「救祓少女·斯特拉」存在的场合，再让自己回复800基本分。
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
-- 过滤函数：判定卡为表侧表示且属于「救祓少女」系列（0x172）的怪兽。
function c16474916.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x172)
end
-- 效果①的发动条件：自己场上有满足cfilter的表侧表示「救祓少女」怪兽存在。
function c16474916.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（LOCATION_MZONE）是否存在至少1张表侧表示且属于「救祓少女」系列的怪兽。
	return Duel.IsExistingMatchingCard(c16474916.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动目标检查：自己场上存在可用主怪兽区空格，且这张卡自身能够被特殊召唤。
function c16474916.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主怪兽区空格（数量大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将特殊召唤这张卡自身（1张），供连锁检测相关效果使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：判定卡为表侧表示且卡号是43863925（「救祓少女·斯特拉」）。
function c16474916.cfilter1(c)
	return c:IsFaceup() and c:IsCode(43863925)
end
-- 效果①处理：特殊召唤自身；若特殊召唤成功且自己场上有「救祓少女·斯特拉」，则中断当前连锁后让自己回复800基本分。
function c16474916.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关，且特殊召唤成功（Duel.SpecialSummon返回值不为0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 并检查自己场上是否存在表侧表示的「救祓少女·斯特拉」（卡号43863925）。
		and Duel.IsExistingMatchingCard(c16474916.cfilter1,tp,LOCATION_ONFIELD,0,1,nil) then
		-- 中断当前效果链，使之后的回复处理视为不同时处理，以正确触发相关时点。
		Duel.BreakEffect()
		-- 让自己回复800基本分，回复原因记为效果（REASON_EFFECT）。
		Duel.Recover(tp,800,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方让自己或对方的卡从墓地离开（即触发效果的控制者为对方rp==1-tp）。
function c16474916.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 选择额外卡组中满足条件的「救祓少女」超量怪兽：属于「救祓少女」系列、为超量怪兽、当前这张卡可作为其超量素材、能够以超量召唤方式特殊召唤，并且有可用的额外怪兽区空格。
function c16474916.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x172) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 该怪兽可以以超量召唤方式特殊召唤，且自己场上（考虑此卡离场后）有足够空间从额外卡组特殊召唤。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动目标检查：此卡不受「必须作为超量素材」限制，且额外卡组存在满足spfilter的超量怪兽。
function c16474916.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否受到“必须作为超量素材”（EFFECT_MUST_BE_XMATERIAL）的限制，若存在则满足发动条件。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 并检查额外卡组中是否存在至少1张满足spfilter的「救祓少女」超量怪兽。
		and Duel.IsExistingMatchingCard(c16474916.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：本次效果处理将从额外卡组特殊召唤1只超量怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：确认此卡可作为素材且在场；选择额外卡组的「救祓少女」超量怪兽，把此卡及其叠放卡全部作为超量素材叠放，以超量召唤方式特殊召唤该怪兽并完成召唤手续。
function c16474916.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认此卡仍满足“必须作为超量素材”的相关条件，否则终止处理。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 向玩家发出选择提示，要求选择要特殊召唤的怪兽（提示信息为“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1张满足spfilter的「救祓少女」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c16474916.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 把这张卡原本持有的叠放卡全部重叠到要特殊召唤的超量怪兽上。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 把这张卡自身作为超量素材叠放到新的超量怪兽下面。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将选择的怪兽以超量召唤（SUMMON_TYPE_XYZ）方式特殊召唤到自己场上。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
