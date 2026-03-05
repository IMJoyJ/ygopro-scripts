--ピュアリィ・シェアリィ！？
-- 效果：
-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。从卡组把1只1星「纯爱妖精」怪兽效果无效特殊召唤，和作为对象的怪兽是属性不同并是阶级相同的1只「纯爱妖精」超量怪兽在那只特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，以下效果可以适用。
-- ●从卡组选1张给作为对象的怪兽作为超量素材中的「纯爱妖精」速攻魔法卡的同名卡作为那只超量召唤的怪兽的超量素材。
local s,id,o=GetID()
-- 创建效果，设置为发动时点，可以选取对象，发动后可以自由连锁，效果描述为选择对象后特殊召唤怪兽
function s.initial_effect(c)
	-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 判断目标是否为己方场上正面表示的纯爱妖精超量怪兽，并且场上有满足条件的超量怪兽可以特殊召唤
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ)
		-- 判断目标是否为己方场上正面表示的纯爱妖精超量怪兽，并且场上有满足条件的超量怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(s.xyzspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank(),c:GetAttribute(),nil)
end
-- 判断额外卡组中是否存在满足条件的纯爱妖精超量怪兽，该怪兽阶级与目标相同但属性不同，且可以被超量召唤
function s.xyzspfilter(c,e,tp,rk,att,mc)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ) and c:IsRank(rk) and not c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 判断该怪兽是否必须作为超量素材
		and aux.MustMaterialCheck(mc,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 判断目标怪兽是否能从额外卡组特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 判断卡组中是否存在1星的纯爱妖精怪兽，且可以特殊召唤
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(0x18c) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否为纯爱妖精速攻魔法卡
function s.xyzfilter1(c,tp)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY)
end
-- 判断是否为纯爱妖精速攻魔法卡且可以叠放，并且在目标怪兽的叠放卡中有同名卡
function s.xyzfilter2(c,og)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY) and c:IsCanOverlay()
		and og:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 设置效果目标，检查是否满足条件，包括己方场上存在符合条件的怪兽和卡组中存在符合条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方是否可以特殊召唤2次
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查己方场上是否存在符合条件的纯爱妖精超量怪兽
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 检查卡组中是否存在1星的纯爱妖精怪兽
		and Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的纯爱妖精超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将特殊召唤2张卡（1张从卡组，1张从额外卡组）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理函数，执行特殊召唤和叠放操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张1星的纯爱妖精怪兽
	local g1=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc1=g1:GetFirst()
	if not sc1 then return end
	-- 将选中的怪兽从卡组效果无效地特殊召唤
	Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
	-- 使特殊召唤的怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e1)
	-- 使特殊召唤的怪兽效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e2)
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的纯爱妖精超量怪兽
	local g2=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank(),tc:GetAttribute(),sc1)
	local sc2=g2:GetFirst()
	if sc2 then
		sc2:SetMaterial(Group.FromCards(sc1))
		-- 将特殊召唤的怪兽叠放至目标怪兽上
		Duel.Overlay(sc2,Group.FromCards(sc1))
		-- 将目标怪兽从额外卡组特殊召唤
		Duel.SpecialSummon(sc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc2:CompleteProcedure()
		local og=tc:GetOverlayGroup():Filter(s.xyzfilter1,nil,tp)
		-- 获取卡组中符合条件的纯爱妖精速攻魔法卡
		local g=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_DECK,0,nil,og)
		-- 判断是否选择将超量素材中的同名卡作为超量素材
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把超量素材的同名卡作为超量素材？"
			-- 提示玩家选择要作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡叠放至目标怪兽上
			Duel.Overlay(sc2,sg:GetFirst())
		end
	end
end
