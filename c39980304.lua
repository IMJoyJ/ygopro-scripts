--チェーン・マテリアル
-- 效果：
-- 这张卡的发动回合自己融合召唤的场合，可以把融合怪兽卡决定的融合素材怪兽从自己的手卡·卡组·场上·墓地选出从游戏中除外，用这些作为融合素材。这张卡发动的回合，自己不能攻击，这个效果融合召唤的怪兽在结束阶段时破坏。
function c39980304.initial_effect(c)
	-- 这张卡的发动回合自己融合召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c39980304.cost)
	e1:SetTarget(c39980304.target)
	e1:SetOperation(c39980304.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：确认本回合尚未进行过攻击后，为玩家场上所有怪兽附加不能攻击的誓约效果，持续到回合结束。
function c39980304.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：玩家在本回合进行的攻击次数必须为0，否则不能发动。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 这张卡发动的回合，自己不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的誓约效果注册到场上，使该限制生效。
	Duel.RegisterEffect(e1,tp)
end
-- 发动时的目标处理：该效果没有取对象，仅确认此效果确实作为魔法卡发动，以通过发动判定。
function c39980304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 发动效果处理：为玩家设置一个持续到结束阶段的‘连锁素材’效果（EFFECT_CHAIN_MATERIAL），本回合融合召唤时可用替代素材。
function c39980304.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 可以把融合怪兽卡决定的融合素材怪兽从自己的手卡·卡组·场上·墓地选出从游戏中除外，用这些作为融合素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(39980304,0))  --"是否使用「连锁素材」的效果？"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c39980304.chain_target)
	e1:SetOperation(c39980304.chain_operation)
	-- 将效果的值设为恒定true，表示该替代融合素材效果对玩家始终有效，无需额外条件。
	e1:SetValue(aux.TRUE)
	-- 将融合素材替代效果注册给当前玩家，使其在本回合持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义可选素材的过滤条件：必须是怪兽卡、可作为融合素材、能够被除外，并且不受该效果免疫。
function c39980304.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 指定融合素材的可选范围：从自己的手卡、卡组、场上、墓地中筛选出满足条件的怪兽作为可用素材。
function c39980304.chain_target(e,te,tp)
	-- 返回当前所有可作为融合素材的怪兽组成的集合。
	return Duel.GetMatchingGroup(c39980304.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,te)
end
-- 执行融合召唤处理：将所选素材除外，进行融合召唤，给融合怪兽附加标记，并注册结束阶段破坏的效果。
function c39980304.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	-- 将融合素材怪兽以表侧表示从游戏中除外，原因设定为效果、作为融合素材、用于融合召唤。
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	-- 中断当前效果处理，使后续的特殊召唤被视为不同时处理，以避免错过时点。
	Duel.BreakEffect()
	-- 将融合怪兽以融合召唤的方式特殊召唤到己方场上（表侧表示），不检查召唤条件与苏生限制。
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(39980304,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
	-- 这个效果融合召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetLabelObject(tc)
	e1:SetCondition(c39980304.descon)
	e1:SetOperation(c39980304.desop)
	e1:SetCountLimit(1)
	-- 将结束时破坏效果注册到场上，使该效果在结束阶段可以发动。
	Duel.RegisterEffect(e1,tp)
end
-- 破坏条件的判定：若该融合怪兽仍带有本次效果标记（39980304），则满足破坏条件；否则重置该效果并不处理。
function c39980304.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(39980304)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段处理：将标记的融合怪兽破坏。
function c39980304.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将指定怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
