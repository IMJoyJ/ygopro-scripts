--インフェルニティ・デストロイヤー
-- 效果：
-- 自己手卡是0张的场合，这张卡战斗破坏对方怪兽送去墓地时，给与对方基本分1600分伤害。
function c98954375.initial_effect(c)
	-- 自己手卡是0张的场合，这张卡战斗破坏对方怪兽送去墓地时，给与对方基本分1600分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98954375,0))  --"给与伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(c98954375.damcon)
	e1:SetTarget(c98954375.damtg)
	e1:SetOperation(c98954375.damop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身与战斗关联、自己手卡为0张，且被破坏的怪兽是因战斗破坏送去墓地的怪兽
function c98954375.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local d=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则将目标怪兽设为被攻击的怪兽
	if d==c then d=Duel.GetAttackTarget() end
	-- 返回自身是否与本次战斗关联，且自己手卡数量是否为0
	return c:IsRelateToBattle() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
		and d:IsLocation(LOCATION_GRAVE) and d:IsReason(REASON_BATTLE) and d:IsType(TYPE_MONSTER)
end
-- 设置效果发动的目标：将对方玩家设为目标玩家，伤害数值设为1600，并向系统申报伤害操作信息
function c98954375.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的目标参数为1600
	Duel.SetTargetParam(1600)
	-- 设置当前连锁的操作信息为给与对方玩家1600分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1600)
end
-- 效果处理：再次确认手卡为0张，获取目标玩家和伤害数值，并给与对方1600分伤害
function c98954375.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果自己手卡数量大于0，则效果不适用
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then return end
	-- 获取当前连锁设定的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
