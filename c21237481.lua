--零式魔導粉砕機
-- 效果：
-- 每把1张魔法卡从手卡丢弃，给与对方基本分500分的伤害。
function c21237481.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：每把1张魔法卡从手卡丢弃，给与对方基本分500分的伤害。
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
-- 过滤函数，用于判断手牌中是否包含可丢弃的魔法卡。
function c21237481.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果的发动费用处理，检查手牌中是否存在满足条件的魔法卡并进行选择和丢弃。
function c21237481.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张魔法卡且可丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c21237481.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的1张手牌。
	local cg=Duel.SelectMatchingCard(tp,c21237481.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为发动费用。
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
-- 设置效果的目标玩家和伤害值。
function c21237481.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为500。
	Duel.SetTargetParam(500)
	-- 设置连锁效果的操作信息为造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果的发动处理，根据连锁信息对对方造成伤害。
function c21237481.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
