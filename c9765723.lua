--戦乙女の契約書
-- 效果：
-- 「女武神的契约书」的①的效果1回合只能使用1次。
-- ①：从手卡把1张「DD」卡或者「契约书」卡送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的恶魔族怪兽的攻击力在对方回合内上升1000。
-- ③：自己准备阶段发动。自己受到1000伤害。
function c9765723.initial_effect(c)
	-- 「女武神的契约书」的卡片发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	-- 设置卡片发动条件为不在伤害计算后（允许在伤害步骤发动但限制在伤害计算前）
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：从手卡把1张「DD」卡或者「契约书」卡送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9765723,0))  --"卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,9765723)
	e2:SetCost(c9765723.descost)
	e2:SetTarget(c9765723.destg)
	e2:SetOperation(c9765723.desop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的恶魔族怪兽的攻击力在对方回合内上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c9765723.atkcon)
	e3:SetTarget(c9765723.atktg)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- ③：自己准备阶段发动。自己受到1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9765723,1))  --"受到伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c9765723.damcon)
	e4:SetTarget(c9765723.damtg)
	e4:SetOperation(c9765723.damop)
	c:RegisterEffect(e4)
end
-- 过滤条件：手卡中的「DD」卡片或「契约书」卡片，且能作为cost送去墓地
function c9765723.cfilter(c)
	return c:IsSetCard(0xaf,0xae) and c:IsAbleToGraveAsCost()
end
-- 破坏效果的Cost：从手卡将1张「DD」卡或「契约书」卡送去墓地
function c9765723.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c9765723.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中满足条件的卡片送去墓地
	Duel.DiscardHand(tp,c9765723.cfilter,1,1,REASON_COST)
end
-- 破坏效果的Target：以场上1张卡为对象，并设置破坏的操作信息
function c9765723.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local xg=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then xg=e:GetHandler() end
	-- 检查场上是否存在可以作为对象的卡片（若此卡刚发动且未适用，则排除此卡自身）
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,xg) end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,xg)
	-- 设置当前连锁的操作信息为“破坏选中的卡片”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的Operation：破坏作为对象的卡片
function c9765723.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 攻击力上升效果的适用条件：当前回合不是自己的回合（即对方回合）
function c9765723.atkcon(e)
	-- 判断当前回合玩家是否不等于此卡控制者（即是否为对方回合）
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 攻击力上升效果的影响对象过滤：自己场上的恶魔族怪兽
function c9765723.atktg(e,c)
	return c:IsRace(RACE_FIEND)
end
-- 准备阶段伤害效果的发动条件：当前回合是自己的回合
function c9765723.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 伤害效果的Target：设置自己为受到伤害的对象，并设置伤害的操作信息
function c9765723.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（伤害数值）设置为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为“给与自己1000点伤害”
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 伤害效果的Operation：给与自己1000点伤害
function c9765723.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
