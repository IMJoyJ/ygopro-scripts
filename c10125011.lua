--星守の騎士団
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·墓地把1只「星骑士」、「星圣」怪兽特殊召唤。
-- ②：以自己场上1只「星骑士」、「星圣」超量怪兽为对象才能发动。和那只自己怪兽阶级不同的1只「星骑士」、「星圣」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c10125011.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·墓地把1只「星骑士」、「星圣」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10125011+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c10125011.activate)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「星骑士」、「星圣」超量怪兽为对象才能发动。和那只自己怪兽阶级不同的1只「星骑士」、「星圣」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,10125012)
	e2:SetTarget(c10125011.sptg)
	e2:SetOperation(c10125011.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，检查卡片是否属于「星骑士」或「星圣」系列。
function c10125011.setcardfilter(c)
	return c:IsSetCard(0x9c,0x53)
end
-- 定义过滤函数，检查卡片是否可以被特殊召唤。
function c10125011.spfilter(c,e,sp)
	return c10125011.setcardfilter(c) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 定义效果①的处理函数，用于从手卡或墓地特殊召唤怪兽。
function c10125011.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从手卡和墓地中检索可特殊召唤且不受王家长眠之谷影响的怪兽组。
	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10125011.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 检查是否存在可特殊召唤的怪兽且主怪兽区有空格。
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 让玩家选择是否进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(10125011,0)) then  --"是否选怪兽特殊召唤？"
		-- 向玩家发送提示消息，选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=cg:Select(tp,1,1,nil)
		-- 将选择的怪兽以正面表示特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤函数，检查场上是否存在符合条件的超量怪兽作为对象。
function c10125011.filter1(c,e,tp)
	return c:IsFaceup() and c10125011.setcardfilter(c) and c:IsType(TYPE_XYZ)
		-- 检查额外卡组中是否存在符合条件的超量怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c10125011.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查怪兽是否必须成为超量素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 定义过滤函数，检查额外卡组中的超量怪兽是否符合条件。
function c10125011.filter2(c,e,tp,mc)
	-- 过滤条件：阶级不同、属于指定系列、是超量怪兽、可以作为素材、可以特殊召唤、有特殊召唤空格。
	return not c:IsRank(mc:GetRank()) and c10125011.setcardfilter(c) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 定义效果②的目标设置函数，用于选择对象和设置操作信息。
function c10125011.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10125011.filter1(chkc,e,tp) end
	-- 检查发动条件，场上是否存在符合条件的超量怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c10125011.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送提示消息，选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 让玩家选择场上一只符合条件的超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c10125011.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将进行特殊召唤，从额外卡组召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果②的处理函数，用于特殊召唤超量怪兽。
function c10125011.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象，即场上选择的超量怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否必须成为超量素材，如果不是则返回。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送提示消息，选择要特殊召唤的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组中选择一只符合条件的超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c10125011.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽的叠放卡转移到新特殊召唤的怪兽下作为超量素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽作为超量素材叠放到新特殊召唤的怪兽下。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的超量怪兽以超量召唤方式特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
