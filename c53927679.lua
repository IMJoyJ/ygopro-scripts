--ファイヤー・トルーパー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，可以把这张卡送去墓地，给与对方基本分1000分伤害。
function c53927679.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，可以把这张卡送去墓地，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53927679,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCost(c53927679.cost)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c53927679.tg)
	e1:SetOperation(c53927679.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 代价函数：检查这张卡能否作为代价送去墓地，若可以则在效果发动时把这张卡送去墓地作为发动代价。
function c53927679.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从场上送去墓地，作为效果发动的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动时的目标设定函数：效果发动时不需要选择卡片对象，而是指定对方玩家为伤害对象，并设置伤害数值1000及对应的操作信息。
function c53927679.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000，表示要给与的伤害数值。
	Duel.SetTargetParam(1000)
	-- 设置效果处理的操作信息：效果类别为伤害（CATEGORY_DAMAGE），目标玩家为对方玩家，伤害数值为1000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害处理函数：效果处理时从连锁信息中取得目标玩家和伤害数值，对对方玩家造成效果伤害。
function c53927679.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和对象参数（伤害数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给目标玩家造成指定数值的效果伤害（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
