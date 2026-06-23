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
-- 过滤「星骑士」或「星圣」卡片
function c10125011.setcardfilter(c)
	return c:IsSetCard(0x9c,0x53)
end
-- 过滤手卡或墓地可特殊召唤的「星骑士」或「星圣」怪兽
function c10125011.spfilter(c,e,sp)
	return c10125011.setcardfilter(c) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 卡片发动时的效果处理
function c10125011.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡或墓地可特殊召唤的「星骑士」或「星圣」怪兽的卡片组
	local cg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c10125011.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	-- 在效果处理时，检查是否有符合条件的怪兽可特殊召唤且主要怪兽区域有空位
	if #cg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否要将怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(10125011,0)) then  --"是否选怪兽特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=cg:Select(tp,1,1,nil)
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上可作为重叠素材的「星骑士」或「星圣」超量怪兽
function c10125011.filter1(c,e,tp)
	return c:IsFaceup() and c10125011.setcardfilter(c) and c:IsType(TYPE_XYZ)
		-- 在效果发动检查时，检查额外卡组是否存在可以重叠在该超量怪兽之上特殊召唤的超量怪兽
		and Duel.IsExistingMatchingCard(c10125011.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 在效果发动检查时，检查该怪兽是否满足必须成为超量素材的限制条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组可重叠在目标超量怪兽上特殊召唤的不同阶级「星骑士」或「星圣」超量怪兽
function c10125011.filter2(c,e,tp,mc)
	-- 返回是否为不同阶级、属于「星骑士」或「星圣」的超量怪兽，且目标怪兽可以作为其超量素材，能在额外怪兽区域特殊召唤
	return not c:IsRank(mc:GetRank()) and c10125011.setcardfilter(c) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 超量特殊召唤效果的发动准备与对象选择
function c10125011.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10125011.filter1(chkc,e,tp) end
	-- 在效果发动检查时，检查场上是否存在可以作为对象的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c10125011.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择作为对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「星骑士」或「星圣」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c10125011.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 超量特殊召唤效果的效果处理
function c10125011.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	-- 在效果处理时，检查目标怪兽是否满足必须成为超量素材的限制条件，不满足则结束处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的额外怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只满足重叠特殊召唤条件的超量怪兽
	local g=Duel.SelectMatchingCard(tp,c10125011.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标超量怪兽持有的超量素材全部重叠到新超量怪兽下
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标超量怪兽自身作为超量素材重叠在新超量怪兽下
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以超量召唤的方式特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
