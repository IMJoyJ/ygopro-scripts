--サイバネティック・フュージョン・サポート
-- 效果：
-- 把基本分支付一半才能发动。这个回合，自己把机械族的融合怪兽融合召唤的场合只有1次，可以把那张融合怪兽卡决定的融合素材怪兽从自己的手卡·场上·墓地选出从游戏中除外，用这些作为融合素材。「电子融合支援」在1回合只能发动1张。
function c58199906.initial_effect(c)
	-- 把基本分支付一半才能发动。这个回合，自己把机械族的融合怪兽融合召唤的场合只有1次，可以把那张融合怪兽卡决定的融合素材怪兽从自己的手卡·场上·墓地选出从游戏中除外，用这些作为融合素材。「电子融合支援」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,58199906+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c58199906.cost)
	e1:SetOperation(c58199906.activate)
	c:RegisterEffect(e1)
end
-- 定义发动的代价（Cost），检查并支付一半的基本分。
function c58199906.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 玩家支付当前一半的基本分。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 魔法卡发动时的效果处理，注册一个改变融合素材选择范围的全局效果。
function c58199906.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己把机械族的融合怪兽融合召唤的场合只有1次，可以把那张融合怪兽卡决定的融合素材怪兽从自己的手卡·场上·墓地选出从游戏中除外，用这些作为融合素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(58199906,0))  --"是否使用「电子融合支援」的效果？"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c58199906.chain_target)
	e1:SetOperation(c58199906.chain_operation)
	-- 设置该融合素材替代效果仅在融合召唤机械族怪兽时适用。
	e1:SetValue(aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE))
	-- 将该效果注册给发动此卡片的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤可以作为融合素材且能被除外的怪兽卡。
function c58199906.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 获取融合素材替代效果的可选卡片范围。
function c58199906.chain_target(e,te,tp)
	-- 检索自己手卡、场上、墓地中满足条件的怪兽卡组。
	return Duel.GetMatchingGroup(c58199906.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,nil,te)
end
-- 执行融合召唤的替代处理，将素材除外并特殊召唤融合怪兽，随后重置该效果（使其仅能使用1次）。
function c58199906.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	-- 将选作融合素材的怪兽表侧表示除外。
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	-- 中断当前效果处理，使后续的特殊召唤不与除外同时处理。
	Duel.BreakEffect()
	-- 将融合怪兽特殊召唤到场上。
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	e:Reset()
end
