--マイティ・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。
function c53981499.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏对方怪兽的场合，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53981499,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c53981499.damcon)
	e1:SetTarget(c53981499.damtg)
	e1:SetOperation(c53981499.damop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否与战斗关联，且被战斗破坏的卡是否为怪兽
function c53981499.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsType(TYPE_MONSTER)
end
-- 伤害效果的发动准备，计算被破坏怪兽攻击力的一半作为伤害值并进行登记
function c53981499.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=math.floor(bc:GetAttack()/2)
	if dam<0 then dam=0 end
	-- 设置效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为给与对方玩家该数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行，获取目标玩家和伤害值并给与伤害
function c53981499.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
