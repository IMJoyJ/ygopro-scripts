--マスクド・チョッパー
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分2000分伤害。
function c87350908.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分2000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87350908,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetTarget(c87350908.damtg)
	e1:SetOperation(c87350908.damop)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标检测与参数设置函数
function c87350908.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为2000
	Duel.SetTargetParam(2000)
	-- 设置当前连锁的操作信息为给与对方玩家2000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 定义效果处理函数，执行伤害效果
function c87350908.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
