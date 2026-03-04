--ピュアリィ・シェアリィ！？
-- 效果：
-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。从卡组把1只1星「纯爱妖精」怪兽效果无效特殊召唤，和作为对象的怪兽是属性不同并是阶级相同的1只「纯爱妖精」超量怪兽在那只特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，以下效果可以适用。
-- ●从卡组选1张给作为对象的怪兽作为超量素材中的「纯爱妖精」速攻魔法卡的同名卡作为那只超量召唤的怪兽的超量素材。
local s,id,o=GetID()
-- 初始化效果函数
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
-- 判断目标怪兽是否满足条件
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的超量怪兽从额外卡组特殊召唤
		and Duel.IsExistingMatchingCard(s.xyzspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank(),c:GetAttribute(),nil)
end
-- 判断超量怪兽是否满足条件
function s.xyzspfilter(c,e,tp,rk,att,mc)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ) and c:IsRank(rk) and not c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查是否必须作为超量素材
		and aux.MustMaterialCheck(mc,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否有足够的额外卡组特殊召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 判断1星纯爱妖精怪兽是否满足条件
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(0x18c) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断速攻魔法卡是否满足条件
function s.xyzfilter1(c,tp)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY)
end
-- 判断速攻魔法卡是否可以作为超量素材
function s.xyzfilter2(c,og)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY) and c:IsCanOverlay()
		and og:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 效果处理目标选择函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	-- 判断是否满足发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤两次
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 判断是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 判断卡组中是否存在满足条件的1星纯爱妖精怪兽
		and Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组选择1星纯爱妖精怪兽
	local g1=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc1=g1:GetFirst()
	if not sc1 then return end
	-- 将选中的怪兽效果无效特殊召唤
	Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
	-- 使特殊召唤的怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e1)
	-- 使特殊召唤的怪兽效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e2)
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 提示玩家选择特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组选择满足条件的超量怪兽
	local g2=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank(),tc:GetAttribute(),sc1)
	local sc2=g2:GetFirst()
	if sc2 then
		sc2:SetMaterial(Group.FromCards(sc1))
		-- 将叠放卡叠放到目标怪兽上
		Duel.Overlay(sc2,Group.FromCards(sc1))
		-- 将目标超量怪兽从额外卡组特殊召唤
		Duel.SpecialSummon(sc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc2:CompleteProcedure()
		local og=tc:GetOverlayGroup():Filter(s.xyzfilter1,nil,tp)
		-- 获取卡组中满足条件的速攻魔法卡
		local g=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_DECK,0,nil,og)
		-- 判断是否选择使用速攻魔法卡作为超量素材
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			-- 提示玩家选择作为超量素材的速攻魔法卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的速攻魔法卡作为超量素材叠放到目标怪兽上
			Duel.Overlay(sc2,sg:GetFirst())
		end
	end
end
