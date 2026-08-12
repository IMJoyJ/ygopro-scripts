--ギガンティック・スプライト
-- 效果：
-- 2星怪兽×2
-- 这张卡超量召唤的场合，可以让自己场上的连接2怪兽作为2星怪兽来成为素材。这个卡名的②的效果1回合只能使用1次。
-- ①：有融合·同调·超量·连接怪兽的其中任意种在作为超量素材中的这张卡的原本攻击力变成2倍。
-- ②：自己主要阶段才能发动。自己场上1个超量素材取除，从卡组把1只2星怪兽特殊召唤。这个效果的发动后，直到回合结束时双方不是2星·2阶·连接2的怪兽不能特殊召唤。
function c54498517.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加无等级限制的超量召唤手续，需要2只满足条件的怪兽作为素材
	aux.AddXyzProcedureLevelFree(c,c54498517.mfilter,nil,2,2)
	-- ①：有融合·同调·超量·连接怪兽的其中任意种在作为超量素材中的这张卡的原本攻击力变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetCondition(c54498517.adcon)
	e1:SetValue(c54498517.atkval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上1个超量素材取除，从卡组把1只2星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,54498517)
	e2:SetTarget(c54498517.sptg)
	e2:SetOperation(c54498517.spop)
	c:RegisterEffect(e2)
end
-- 超量素材过滤：等级为2的怪兽，或者连接标记为2的怪兽（作为2星怪兽）
function c54498517.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,2) or c:IsLink(2)
end
-- 原本攻击力翻倍效果的判定条件：超量素材中存在融合、同调、超量或连接怪兽
function c54498517.adcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 原本攻击力翻倍效果的数值计算：返回自身原本攻击力的2倍
function c54498517.atkval(e,c)
	return c:GetBaseAttack()*2
end
-- 特殊召唤的怪兽过滤：等级为2且可以被特殊召唤的怪兽
function c54498517.spfilter(c,e,tp)
	return c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检测
function c54498517.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否能以效果原因去除至少1个超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT)
		-- 检测自己场上是否有可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己卡组中是否存在至少1只满足特殊召唤条件的2星怪兽
		and Duel.IsExistingMatchingCard(c54498517.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理逻辑：去除素材，从卡组特召2星怪兽，并施加双方特召限制
function c54498517.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足特殊召唤条件的2星怪兽
	local g=Duel.GetMatchingGroup(c54498517.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 尝试从自己场上成功去除1个超量素材
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0
		-- 如果自己场上有怪兽区域空位，且卡组中存在可特召的2星怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时双方不是2星·2阶·连接2的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c54498517.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制效果，使其对双方玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的判定：不能特殊召唤不是2星、2阶或连接2的怪兽
function c54498517.splimit(e,c)
	return not c:IsLevel(2) and not c:IsRank(2) and not c:IsLink(2)
end
