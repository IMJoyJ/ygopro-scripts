--鎧竜－アームド・ドラゴン－
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。从手卡·卡组把「铠龙-武装龙-」以外的1只5星以下的龙族·风属性怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c75220074.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。从手卡·卡组把「铠龙-武装龙-」以外的1只5星以下的龙族·风属性怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置①效果的发动条件为「这张卡在战斗中破坏了对方怪兽」。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c75220074.sptg)
	e1:SetOperation(c75220074.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为「铠龙-武装龙-」以外、5星以下的龙族·风属性且可特殊召唤的怪兽。
function c75220074.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(5)
		and not c:IsCode(75220074) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数：检查自己怪兽区空位及手卡·卡组是否存在符合条件的怪兽。
function c75220074.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己怪兽区至少有1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己手卡或卡组存在至少1只符合条件的龙族·风属性怪兽。
		and Duel.IsExistingMatchingCard(c75220074.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的处理函数：从手卡·卡组特招1只符合条件的怪兽，并赋予其本回合不能直接攻击的限制。
function c75220074.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时检查自己怪兽区是否有空位，没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送提示信息，引导玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·卡组选择1只满足条件的龙族·风属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c75220074.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 分步将所选怪兽以表侧表示特殊召唤到自己场上，并判断是否成功。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 结算分步特殊召唤流程，完成特殊召唤。
	Duel.SpecialSummonComplete()
end
