--RUM－ソウル・シェイブ・フォース
-- 效果：
-- ①：把基本分支付一半，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，比那只怪兽阶级高2阶的1只超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c23581825.initial_effect(c)
	-- ①：把基本分支付一半，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_DESTROY)
	e1:SetCost(c23581825.cost)
	e1:SetTarget(c23581825.target)
	e1:SetOperation(c23581825.activate)
	c:RegisterEffect(e1)
end
-- 支付一半基本分作为发动cost
function c23581825.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前玩家基本分的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤满足条件的墓地「急袭猛禽」超量怪兽
function c23581825.filter1(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足条件的额外卡组超量怪兽
		and Duel.IsExistingMatchingCard(c23581825.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+2)
end
-- 过滤满足条件的额外卡组超量怪兽
function c23581825.filter2(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk) and mc:IsCanBeXyzMaterial(c)
		-- 检查目标超量怪兽是否可以特殊召唤且有足够召唤区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标为满足条件的墓地「急袭猛禽」超量怪兽
function c23581825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23581825.filter1(chkc,e,tp) end
	-- 检查玩家是否可以进行2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否满足作为超量素材的条件
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否存在满足条件的墓地「急袭猛禽」超量怪兽
		and Duel.IsExistingTarget(c23581825.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地「急袭猛禽」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c23581825.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
-- 处理效果的发动
function c23581825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 将目标怪兽特殊召唤到场上
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查目标怪兽是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组超量怪兽
	local g=Duel.SelectMatchingCard(tp,c23581825.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+2)
	local sc=g:GetFirst()
	if sc then
		-- 中断当前效果处理
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放至选择的超量怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的超量怪兽从额外卡组特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
