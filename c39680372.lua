--創造の聖刻印
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只龙族超量怪兽为对象才能发动。原本卡名和那只自己怪兽不同的1只「圣刻」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「圣刻」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c39680372.initial_effect(c)
	-- ①：以自己场上1只龙族超量怪兽为对象才能发动。原本卡名和那只自己怪兽不同的1只「圣刻」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39680372,0))  --"超量召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39680372)
	e1:SetTarget(c39680372.target)
	e1:SetOperation(c39680372.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「圣刻」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39680372,1))  --"墓地苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39680372)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39680372.sptg)
	e2:SetOperation(c39680372.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽，必须为龙族、超量、正面表示、且其作为对象的怪兽不同名、且能成为超量素材
function c39680372.filter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
		-- 检查场上是否存在满足条件的额外卡组怪兽
		and Duel.IsExistingMatchingCard(c39680372.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查目标怪兽是否满足作为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤满足条件的额外卡组怪兽，必须为圣刻族、超量、不同名、能成为超量素材、能特殊召唤、且有足够召唤空间
function c39680372.filter2(c,e,tp,mc)
	return c:IsSetCard(0x69) and c:IsType(TYPE_XYZ) and not c:IsCode(mc:GetOriginalCode()) and mc:IsCanBeXyzMaterial(c)
		-- 检查额外卡组怪兽是否能特殊召唤且有召唤空间
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标为己方场上满足条件的怪兽，准备特殊召唤
function c39680372.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c39680372.filter1(chkc,e,tp) end
	-- 检查是否存在满足条件的己方场上怪兽
	if chk==0 then return Duel.IsExistingTarget(c39680372.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的己方场上怪兽作为效果对象
	Duel.SelectTarget(tp,c39680372.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的特殊召唤操作，将目标怪兽叠放并特殊召唤
function c39680372.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c39680372.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到特殊召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到特殊召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将特殊召唤的怪兽以超量召唤方式特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 过滤满足条件的墓地怪兽，必须为圣刻族、能守备表示特殊召唤
function c39680372.spfilter(c,e,tp)
	return c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标为己方墓地满足条件的怪兽，准备特殊召唤
function c39680372.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c39680372.spfilter(chkc,e,tp) end
	-- 检查己方场上是否有召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的己方墓地怪兽
		and Duel.IsExistingTarget(c39680372.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的己方墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c39680372.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的特殊召唤操作，将目标怪兽守备表示特殊召唤
function c39680372.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
