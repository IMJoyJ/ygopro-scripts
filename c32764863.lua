--エクシーズ・リバイブ・スプラッシュ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只4阶以下的超量怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽变成水属性。
-- ②：把墓地的这张卡除外，以自己场上1只水属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只水属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c32764863.initial_effect(c)
	-- ①：以自己墓地1只4阶以下的超量怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽变成水属性。
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
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c32764863.rktg)
	e2:SetOperation(c32764863.rkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地的怪兽是否满足4阶以下且可特殊召唤的条件
function c32764863.cfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRankBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果①的发动时点，检查是否有满足条件的怪兽可选择
function c32764863.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32764863.cfilter(chkc,e,tp) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否有满足条件的怪兽
		and Duel.IsExistingTarget(c32764863.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c32764863.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果①的发动效果，将选中的怪兽特殊召唤并变为水属性
function c32764863.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 创建一个改变属性的效果，使怪兽变为水属性
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_WATER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤函数，用于判断场上水属性超量怪兽是否满足条件
function c32764863.rkfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
		-- 检查对象怪兽是否满足成为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否有满足条件的超量怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(c32764863.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end
-- 过滤函数，用于判断额外卡组的超量怪兽是否满足条件
function c32764863.spfilter(c,e,tp,mc,rank)
	return c:IsRank(rank+1) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查额外卡组的超量怪兽是否可特殊召唤且场上空间足够
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 处理效果②的发动时点，检查是否有满足条件的怪兽可选择
function c32764863.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c32764863.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c32764863.rkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的场上怪兽作为对象
	local g=Duel.SelectTarget(tp,c32764863.rkfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将要从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果②的发动效果，将选中的怪兽特殊召唤并叠放素材
function c32764863.rkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否满足成为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的超量怪兽
	local g=Duel.SelectMatchingCard(tp,c32764863.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽的叠放卡叠放到目标怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽叠放到目标怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将目标怪兽从额外卡组特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
