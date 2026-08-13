--マスドライバー
-- 效果：
-- 每祭掉自己场上1只怪兽，给与对方基本分400分的伤害。
function c34906152.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每祭掉自己场上1只怪兽，给与对方基本分400分的伤害。
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
-- 代价函数：确认自己场上存在可解放的怪兽，选择1只自己场上的怪兽解放作为发动代价。
function c34906152.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查自己场上是否存在至少1只可解放的怪兽（chk==0时）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择自己场上1只可解放的怪兽作为解放代价（aux.TRUE表示任意怪兽）。
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 将选择的怪兽解放（作为代价，不进入连锁）。
	Duel.Release(g,REASON_COST)
end
-- 效果对象设定函数：效果发动时指定对方玩家为伤害对象，伤害值为400，并设置操作信息为造成伤害。
function c34906152.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设置为400（伤害数值）。
	Duel.SetTargetParam(400)
	-- 设置操作信息：本次连锁将造成效果伤害，目标玩家为对方，伤害值为400（用于时点/响应检测）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 效果处理函数：取得连锁中记录的对象玩家和伤害值，对对方造成400点伤害。
function c34906152.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
