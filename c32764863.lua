--エクシーズ・リバイブ・スプラッシュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只4阶以下的超量怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽变成水属性。
-- ②：把墓地的这张卡除外，以自己场上1只水属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只水属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c32764863.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己墓地1只4阶以下的超量怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽变成水属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32764863,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,32764863)
	e1:SetTarget(c32764863.target)
	e1:SetOperation(c32764863.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己场上1只水属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只水属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32764863,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,32764863)
	-- 设置发动代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32764863.rktg)
	e2:SetOperation(c32764863.rkop)
	c:RegisterEffect(e2)
end
-- 过滤条件函数：筛选阶级4以下且可被特殊召唤的超量怪兽
function c32764863.cfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRankBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择与合法性检查函数：检查场上是否有怪兽区空位且墓地存在符合条件的4阶以下超量怪兽
function c32764863.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32764863.cfilter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否存在可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可成为对象的4阶以下超量怪兽
		and Duel.IsExistingTarget(c32764863.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c32764863.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记操作信息：将会特殊召唤所选对象的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理函数：若对象仍在墓地且与效果关联，则将其表侧表示特殊召唤，并使其属性变成水属性
function c32764863.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象选择的墓地超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽变成水属性。 ②：把墓地的这张卡除外，以自己场上1只水属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只水属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_WATER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤条件函数：筛选自己场上表侧表示的水属性超量怪兽，且不受禁止作超量素材限制，同时额外卡组存在高1阶的水属性超量怪兽
function c32764863.rkfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
		-- 检查该怪兽是否满足“必须作为超量素材”的效果限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查自己额外卡组是否存在比该怪兽阶级高1阶且可叠放超量召唤的水属性超量怪兽
		and Duel.IsExistingMatchingCard(c32764863.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
-- 过滤条件函数：筛选比指定怪兽阶级高1阶、水属性、能以该怪兽为素材超量召唤且额外怪兽区有空位的超量怪兽
function c32764863.spfilter(c,e,tp,mc,rank)
	return c:IsRank(rank+1) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽能否被当作超量召唤特殊召唤，且以其下级怪兽离场后场上仍有可出场的怪兽区空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的目标选择函数：检查自己场上是否存在符合条件的水属性超量怪兽，选择其中1只作为对象并登记从额外卡组特殊召唤的操作信息
function c32764863.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c32764863.rkfilter(chkc,e,tp) end
	-- 发动条件检查：确认自己场上存在至少1只可成为对象的符合条件的水属性超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c32764863.rkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择提示：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的水属性超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c32764863.rkfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 向系统登记操作信息：将会从自己额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数开头：获取对象怪兽并确认其仍表侧表示存在、由自己控制、与效果关联且不受效果免疫与超量素材限制
function c32764863.rkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象选择的自己场上超量怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否因受限于其他卡的“必须作为超量素材”效果而无法成为本次升阶超量召唤的素材
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择提示：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己额外卡组选择1只比对象怪兽高1阶的符合条件的水属性超量怪兽
	local g=Duel.SelectMatchingCard(tp,c32764863.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本拥有的超量素材全部转移叠放到新超量怪兽下方
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽自身叠放到新超量怪兽下方作为超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的额外卡组超量怪兽以表侧表示当作超量召唤特殊召唤到自己场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
