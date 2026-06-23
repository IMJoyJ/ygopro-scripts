--チェーン・マテリアル
-- 效果：
-- 这张卡的发动回合自己融合召唤的场合，可以把融合怪兽卡决定的融合素材怪兽从自己的手卡·卡组·场上·墓地选出从游戏中除外，用这些作为融合素材。这张卡发动的回合，自己不能攻击，这个效果融合召唤的怪兽在结束阶段时破坏。
function c39980304.initial_effect(c)
	-- 这张卡发动时，自己不能攻击，这个效果融合召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c39980304.cost)
	e1:SetTarget(c39980304.target)
	e1:SetOperation(c39980304.activate)
	c:RegisterEffect(e1)
end
-- 检查是否在发动回合攻击过，若未攻击则继续执行
function c39980304.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未攻击则返回true，表示可以发动
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 注册一个效果，使自己在该回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 检查是否为发动效果
function c39980304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 创建一个效果，用于改变融合素材选取方式
function c39980304.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果为连锁素材效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(39980304,0))  --"是否使用「连锁素材」的效果？"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c39980304.chain_target)
	e1:SetOperation(c39980304.chain_operation)
	-- 设置效果值为始终成立
	e1:SetValue(aux.TRUE)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，筛选可作为融合素材的怪兽
function c39980304.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义连锁素材的选取目标函数
function c39980304.chain_target(e,te,tp)
	-- 获取满足条件的融合素材怪兽组
	return Duel.GetMatchingGroup(c39980304.filter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,te)
end
-- 定义连锁素材的效果处理函数
function c39980304.chain_operation(e,te,tp,tc,mat,sumtype)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	-- 将指定的融合素材从游戏中除外
	Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 将融合怪兽特殊召唤
	Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	tc:RegisterFlagEffect(39980304,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET,0,1)
	-- 注册一个在结束阶段时破坏融合怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetLabelObject(tc)
	e1:SetCondition(c39980304.descon)
	e1:SetOperation(c39980304.desop)
	e1:SetCountLimit(1)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断融合怪兽是否还在场上
function c39980304.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(39980304)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 破坏融合怪兽
function c39980304.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因破坏融合怪兽
	Duel.Destroy(tc,REASON_EFFECT)
end
