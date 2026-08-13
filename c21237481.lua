--零式魔導粉砕機
-- 效果：
-- 每把1张魔法卡从手卡丢弃，给与对方基本分500分的伤害。
function c21237481.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每把1张魔法卡从手卡丢弃，给与对方基本分500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21237481,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c21237481.cost)
	e2:SetTarget(c21237481.target)
	e2:SetOperation(c21237481.operation)
	c:RegisterEffect(e2)
end
-- 筛选可作为代价丢弃的魔法卡：必须是魔法卡且满足可丢弃条件。
function c21237481.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 支付代价：检测手牌中是否存在可丢弃的魔法卡，选择1张丢弃并送入墓地。
function c21237481.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认手牌中存在至少1张可丢弃的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21237481.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 给玩家弹出选择提示，内容为“请选择要丢弃的手牌”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家从手卡选择1张满足条件的魔法卡作为代价。
	local cg=Duel.SelectMatchingCard(tp,c21237481.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选魔法卡以“代价+丢弃”的原因送入墓地。
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
-- 发动时设定对象玩家为对方、伤害数值为500，并登记操作信息为给予伤害。
function c21237481.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次效果的对象参数设置为500，即伤害数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：本连锁将对对方玩家造成500点伤害，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理阶段：读取目标玩家和伤害数值，实际给予对方伤害。
function c21237481.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和伤害数值（之前保存的500）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成500点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
