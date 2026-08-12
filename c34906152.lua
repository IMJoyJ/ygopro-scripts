--マスドライバー
-- 效果：
-- 每祭掉自己场上1只怪兽，给与对方基本分400分的伤害。
function c34906152.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 给予对方400分伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34906152,0))  --"给予对方400分伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c34906152.damcost)
	e2:SetTarget(c34906152.damtg)
	e2:SetOperation(c34906152.damop)
	c:RegisterEffect(e2)
end
-- 检查并选择1只自己场上的怪兽进行解放作为代价
function c34906152.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择1只自己场上的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 将选中的怪兽解放并视为支付代价
	Duel.Release(g,REASON_COST)
end
-- 设置连锁处理时的目标玩家和伤害值
function c34906152.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理时的伤害值为400
	Duel.SetTargetParam(400)
	-- 设置连锁操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 执行伤害效果，对目标玩家造成指定伤害
function c34906152.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
