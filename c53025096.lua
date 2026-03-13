--オッドアイズ・ドラゴン
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
function c53025096.initial_effect(c)
	-- 效果原文内容：①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53025096,0))  --"基本分伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c53025096.damcon)
	e1:SetTarget(c53025096.damtg)
	e1:SetOperation(c53025096.damop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断进行战斗的怪兽是否参与了战斗且被破坏送入墓地，且破坏的怪兽是怪兽类型。
function c53025096.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 规则层面操作：计算对方怪兽的原本攻击力的一半作为伤害值，并设置连锁处理的目标卡片、目标玩家和伤害参数。
function c53025096.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=math.floor(bc:GetBaseAttack()/2)
	-- 规则层面操作：将当前战斗中被破坏的对方怪兽设为连锁处理的对象卡片。
	Duel.SetTargetCard(bc)
	-- 规则层面操作：将对方玩家设为连锁处理的对象玩家（即受到伤害的玩家）。
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面操作：设置连锁处理的目标参数为计算出的伤害值。
	Duel.SetTargetParam(dam)
	-- 规则层面操作：设置当前连锁的操作信息为伤害效果，目标玩家和伤害值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 规则层面操作：执行伤害效果，对指定玩家造成相应数值的伤害。
function c53025096.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁处理的目标卡片（即被破坏的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面操作：从当前连锁中获取目标玩家信息（即受到伤害的玩家）。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.floor(tc:GetBaseAttack()/2)
		-- 规则层面操作：以效果为原因，对指定玩家造成相应数值的伤害。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
