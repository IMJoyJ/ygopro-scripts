--ダークブレイズドラゴン
-- 效果：
-- ①：这张卡从墓地的特殊召唤成功的场合发动。这张卡的攻击力·守备力变成原本数值的2倍。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c39343610.initial_effect(c)
	-- ①：这张卡从墓地的特殊召唤成功的场合发动。这张卡的攻击力·守备力变成原本数值的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39343610,0))  --"攻守变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39343610.atkcon)
	e1:SetOperation(c39343610.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39343610,1))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c39343610.damcon)
	e2:SetTarget(c39343610.damtg)
	e2:SetOperation(c39343610.damop)
	c:RegisterEffect(e2)
end
-- 发动条件判断：检查这张卡在特殊召唤成功之前是否位于墓地，即是否从墓地特殊召唤成功。
function c39343610.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果处理：若这张卡仍表侧表示且与效果关联，则注册攻击力和守备力变为原本数值2倍的持续效果。
function c39343610.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力变成原本数值的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 这张卡的守备力变成原本数值的2倍。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(c:GetBaseDefense()*2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
-- 诱发条件判断：这张卡进行战斗，战斗对象是被这张卡战斗破坏并送去墓地的怪兽。
function c39343610.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 发动时处理：将对方玩家设为效果对象玩家，伤害值设为战斗破坏怪兽的攻击力（低于0按0计），并写入连锁操作信息。
function c39343610.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 将当前连锁的效果对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果对象参数设置为伤害数值dam。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：宣告本次效果将给对方造成dam点伤害，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：从连锁信息中取得目标玩家和伤害数值，并实际给予对方伤害。
function c39343610.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象玩家和对象参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因为原因对目标玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
