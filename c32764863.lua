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
	-- ②：把墓地的这张卡除外，以自己场上1只水属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只水属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32764863,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,32764863)
	-- 设置②效果发动时把墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32764863.rktg)
	e2:SetOperation(c32764863.rkop)
	c:RegisterEffect(e2)
end
-- 定义①效果对象筛选条件：自己墓地的4阶以下超量怪兽，且能被效果特殊召唤。
function c32764863.cfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRankBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标指定与发动条件判断：检查对象须为自己墓地可特殊召唤的4阶以下超量怪兽，并有可用的主要怪兽区。
function c32764863.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32764863.cfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在满足条件且能成为对象的超量怪兽。
		and Duel.IsExistingTarget(c32764863.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c32764863.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁的特殊召唤相关信息，用于后续时点与连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将对象怪兽表侧表示特殊召唤，并让它变成水属性。
function c32764863.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以正面表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽变成水属性。②：把墓地的这张卡除外，以自己场上1只水属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只水属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_WATER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 定义②效果对象的筛选条件：自己场上表侧表示的水属性超量怪兽，且能作为超量素材，且额外卡组存在可叠放的高1阶水属性超量怪兽。
function c32764863.rkfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
		-- 确认对象怪兽没有‘必须作为超量素材’的限制或满足该制约。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在符合条件的、比对象阶级高1阶的水属性超量怪兽，且能满足特殊召唤条件。
		and Duel.IsExistingMatchingCard(c32764863.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
-- 定义额外卡组可特殊召唤的怪兽条件：阶级为对象阶级+1的水属性超量怪兽，可用对象作素材，能以超量召唤方式特殊召唤，且额外卡组怪兽区有空位。
function c32764863.spfilter(c,e,tp,mc,rank)
	return c:IsRank(rank+1) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 确认该额外怪兽能以超量召唤方式特殊召唤，且从额外卡组出场时有可用区域。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的目标指定与发动条件判断：选择自己场上1只水属性超量怪兽作为对象，并登记额外卡组特殊召唤操作信息。
function c32764863.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c32764863.spfilter(chkc,e,tp) end
	-- 发动条件：自己场上存在满足②效果对象条件的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c32764863.rkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只水属性超量怪兽作为②效果对象。
	local g=Duel.SelectTarget(tp,c32764863.rkfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记②效果要从额外卡组特殊召唤的信息（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理前合法性检查：对象必须仍满足作为超量素材的制约、表侧存在、与效果关联、控制权未转移且不受效果免疫；否则不处理。
function c32764863.rkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍满足‘必须作为超量素材’的制约，不满足则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的额外卡组怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的水属性超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c32764863.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象原本叠放的所有超量素材移到新怪兽下方。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽本身也叠放到新怪兽下方作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的新怪兽以超量召唤方式特殊召唤到自己场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
