--鎧竜－アームド・ドラゴン－
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。从手卡·卡组把「铠龙-武装龙-」以外的1只5星以下的龙族·风属性怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
function c75220074.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时才能发动。从手卡·卡组把「铠龙-武装龙-」以外的1只5星以下的龙族·风属性怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为这张卡战斗破坏对方怪兽时
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c75220074.sptg)
	e1:SetOperation(c75220074.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：手卡·卡组中「铠龙-武装龙-」以外的5星以下的龙族·风属性且可以特殊召唤的怪兽
function c75220074.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(5)
		and not c:IsCode(75220074) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数
function c75220074.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c75220074.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理的执行函数
function c75220074.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c75220074.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若存在选择的怪兽，则尝试将其以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
