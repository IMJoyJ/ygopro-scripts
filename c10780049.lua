--ピュアリィ・シェアリィ！？
-- 效果：
-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。从卡组把1只1星「纯爱妖精」怪兽效果无效特殊召唤，和作为对象的怪兽是属性不同并是阶级相同的1只「纯爱妖精」超量怪兽在那只特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，以下效果可以适用。
-- ●从卡组选1张给作为对象的怪兽作为超量素材中的「纯爱妖精」速攻魔法卡的同名卡作为那只超量召唤的怪兽的超量素材。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：作为速攻魔法在自由时点发动，取对象，且涉及特殊召唤；同时指定目标筛选函数和效果处理函数。
function s.initial_effect(c)
	-- ①：以自己场上1只「纯爱妖精」超量怪兽为对象才能发动。从卡组把1只1星「纯爱妖精」怪兽效果无效特殊召唤，和作为对象的怪兽是属性不同并是阶级相同的1只「纯爱妖精」超量怪兽在那只特殊召唤的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，以下效果可以适用。●从卡组选1张给作为对象的怪兽作为超量素材中的「纯爱妖精」速攻魔法卡的同名卡作为那只超量召唤的怪兽的超量素材。
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
-- 定义可取对象的怪兽：自己场上表侧表示且卡名属于「纯爱妖精」的超量怪兽，并额外确认存在可进行后续超量召唤的额外怪兽。
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在满足阶级相同、属性不同且可以特殊召唤的「纯爱妖精」超量怪兽（此阶段素材参数为空，仅确认存在可能性）。
		and Duel.IsExistingMatchingCard(s.xyzspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank(),c:GetAttribute(),nil)
end
-- 筛选额外卡组中可超量召唤的候选怪兽：须是「纯爱妖精」超量怪兽，阶级与对象怪兽相同、属性不同，能够以超量召唤方式特殊召唤，且素材怪兽和额外区条件满足。
function s.xyzspfilter(c,e,tp,rk,att,mc)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_XYZ) and c:IsRank(rk) and not c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 确认素材怪兽（特殊召唤的1星「纯爱妖精」）没有受到“必须作为超量素材”等限制，可以正常作为超量素材使用。
		and aux.MustMaterialCheck(mc,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认素材怪兽作为叠放素材离场后，额外卡组怪兽仍有足够的出场区域可以特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 筛选卡组中可被效果特殊召唤的1星「纯爱妖精」怪兽（作为从卡组特殊召唤的素材）。
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(0x18c) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 从对象怪兽的超量素材中筛选出「纯爱妖精」速攻魔法卡，用于后续检索同名卡。
function s.xyzfilter1(c,tp)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY)
end
-- 筛选卡组中与对象怪兽持有的「纯爱妖精」速攻魔法同名的速攻魔法卡，且该卡可以叠放作为超量素材。
function s.xyzfilter2(c,og)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY) and c:IsCanOverlay()
		and og:IsExists(Card.IsCode,1,nil,c:GetCode())
end
-- 效果发动条件判定：需自己场上存在可对象化的「纯爱妖精」超量怪兽、卡组有1星「纯爱妖精」可特召、场上有空格且当回合可特召次数≥2；若为连锁处理中的对象合法性检查，则直接判定对象是否合法。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区有至少1个空格，用于特殊召唤卡组中的1星「纯爱妖精」怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之一：本回合仍有2次特殊召唤次数，因为此效果会先后特殊召唤2只怪兽。
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 发动条件之一：场上存在满足条件的「纯爱妖精」超量怪兽可以选择为对象。
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 发动条件之一：卡组中存在1星「纯爱妖精」怪兽可以被此效果特殊召唤。
		and Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向玩家发出“请选择效果的对象”的提示消息，准备选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「纯爱妖精」超量怪兽作为效果对象，并登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次处理将特殊召唤2只怪兽，来源包括卡组和额外卡组，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理流程：取得对象后，从卡组特殊召唤1只1星「纯爱妖精」（效果无效化），将其作为素材叠放，超量召唤符合条件的额外「纯爱妖精」超量怪兽；之后可选将对象持有的同名速攻魔法作为追加素材。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽（即用来确定阶级/属性和后续素材来源的「纯爱妖精」超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家发出“请选择要特殊召唤的卡”的提示消息，准备从卡组选怪。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的1星「纯爱妖精」怪兽（因为发动时已确认存在，必选1张）。
	local g1=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc1=g1:GetFirst()
	if not sc1 then return end
	-- 将选出的1星「纯爱妖精」怪兽以表侧表示加入特殊召唤序列（尚未正式召唤，以便立即附加无效效果）。
	Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
	-- 从卡组把1只1星「纯爱妖精」怪兽效果无效特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e1)
	-- 从卡组把1只1星「纯爱妖精」怪兽效果无效特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc1:RegisterEffect(e2)
	-- 完成之前累积的特殊召唤处理，正式将1星「纯爱妖精」怪兽特殊召唤到场上。
	Duel.SpecialSummonComplete()
	-- 向玩家发出“请选择要特殊召唤的卡”的提示消息，准备从额外选超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「纯爱妖精」超量怪兽：阶级与对象怪兽相同、属性不同，且能以刚特殊召唤的1星怪兽为素材进行超量召唤。
	local g2=Duel.SelectMatchingCard(tp,s.xyzspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank(),tc:GetAttribute(),sc1)
	local sc2=g2:GetFirst()
	if sc2 then
		sc2:SetMaterial(Group.FromCards(sc1))
		-- 将1星怪兽作为超量素材叠放在超量怪兽下面，实现在其上面重叠并当作超量召唤。
		Duel.Overlay(sc2,Group.FromCards(sc1))
		-- 将选择的额外「纯爱妖精」超量怪兽以超量召唤的方式特殊召唤到场上。
		Duel.SpecialSummon(sc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc2:CompleteProcedure()
		local og=tc:GetOverlayGroup():Filter(s.xyzfilter1,nil,tp)
		-- 从卡组筛选与对象怪兽所持「纯爱妖精」速攻魔法同名的速攻魔法卡，作为后续可选附加素材的候选。
		local g=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_DECK,0,nil,og)
		-- 如果卡组存在候选同名速攻魔法，且玩家选择“是”，则执行效果原文中“那之后，以下效果可以适用”的追加素材处理。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把超量素材的同名卡作为超量素材？"
			-- 向玩家发出“请选择要作为超量素材的卡”的提示消息，准备选择同名速攻魔法。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选出的速攻魔法卡叠放在超量召唤的怪兽下面，作为其超量素材。
			Duel.Overlay(sc2,sg:GetFirst())
		end
	end
end
