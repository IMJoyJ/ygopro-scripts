--ラヴァルのマグマ砲兵
-- 效果：
-- 从手卡把1只炎属性怪兽送去墓地发动。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
function c46404281.initial_effect(c)
	-- 从手卡把1只炎属性怪兽送去墓地发动。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46404281,0))  --"给与对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c46404281.damcost)
	e1:SetTarget(c46404281.damtg)
	e1:SetOperation(c46404281.damop)
	c:RegisterEffect(e1)
end
-- 定义代价滤卡条件：筛选手牌中满足炎属性且可以作为代价送去墓地的怪兽。
function c46404281.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 发动代价处理：确认存在合法代价后，提示玩家选择手牌中1只炎属性怪兽，将其作为代价送去墓地。
function c46404281.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手牌中是否存在至少1只满足条件的炎属性怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46404281.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家发送选择提示，提示内容是“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择1只满足条件的炎属性怪兽，作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c46404281.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽以代价（REASON_COST）形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 发动目标的设定：该效果以对方玩家为对象，设置伤害数值为500，并登记效果处理时的伤害信息。
function c46404281.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的目标玩家为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为伤害数值500。
	Duel.SetTargetParam(500)
	-- 登记操作信息：表示该连锁将造成500点效果伤害，目标为对方玩家，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：从连锁信息中取得目标玩家和伤害数值，并执行伤害。
function c46404281.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中登记的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成效果伤害，伤害数值为之前登记的500点。
	Duel.Damage(p,d,REASON_EFFECT)
end
