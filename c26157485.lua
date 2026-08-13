--C・シューター
-- 效果：
-- 把自己场上存在的1只名字带有「链」的怪兽送去墓地发动。给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c26157485.initial_effect(c)
	-- 把自己场上存在的1只名字带有「链」的怪兽送去墓地发动。给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26157485,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26157485.damcost)
	e1:SetTarget(c26157485.damtg)
	e1:SetOperation(c26157485.damop)
	c:RegisterEffect(e1)
end
-- 定义代价过滤函数：判定怪兽是否满足作为发动代价的条件——表侧表示且名字带有「链」字段，并且可以作为代价送去墓地。
function c26157485.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x25) and c:IsAbleToGraveAsCost()
end
-- 代价函数：在发动时确认能否支付代价，若可以则提示玩家选择1张满足条件的怪兽，将其送去墓地作为发动代价。
function c26157485.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认自己场上是否存在至少1张满足条件的表侧表示名字带有「链」且可作为代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c26157485.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张满足条件的怪兽（表侧表示、名字带有「链」且可作为代价送去墓地）作为代价。
	local g=Duel.SelectMatchingCard(tp,c26157485.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽以代价形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标设定函数：设置对象玩家为对方、伤害数值为800，并登记操作信息为伤害效果。
function c26157485.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设置为伤害数值800。
	Duel.SetTargetParam(800)
	-- 登记操作信息：本连锁将造成伤害效果，对象为对方玩家，数值为800。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理函数：实际执行给予对方基本分800分伤害。
function c26157485.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁记录的对象玩家和伤害参数（即对方玩家和800）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害方式给予对象玩家（对方）800点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
