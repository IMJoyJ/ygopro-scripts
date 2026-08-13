--ドンヨリボー＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的「@火灵天星」怪兽被攻击的伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0。
-- ②：「@火灵天星」怪兽或者「“艾”」魔法·陷阱卡的给与对方伤害的效果发动时，把墓地的这张卡除外才能发动（伤害步骤也能发动）。那个效果给与对方的伤害变成2倍。
function c14146794.initial_effect(c)
	-- ①：自己的「@火灵天星」怪兽被攻击的伤害计算时把这张卡从手卡丢弃才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14146794,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14146794)
	e1:SetCondition(c14146794.damcon1)
	e1:SetCost(c14146794.damcost1)
	e1:SetOperation(c14146794.damop1)
	c:RegisterEffect(e1)
	-- ②：「@火灵天星」怪兽或者「“艾”」魔法·陷阱卡的给与对方伤害的效果发动时，把墓地的这张卡除外才能发动（伤害步骤也能发动）。那个效果给与对方的伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14146794,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,14146795)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c14146794.damcon2)
	-- 为②效果设置发动代价：把墓地的这张卡除外（使用 aux.bfgcost 作为COST函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c14146794.damop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：自己场上的「@火灵天星」怪兽成为攻击对象，且本次战斗自己将受到的战斗伤害大于0。
function c14146794.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中受到攻击的怪兽对象（攻击目标）。
	local d=Duel.GetAttackTarget()
	-- 判定攻击目标存在、为己方控制的「@火灵天星」怪兽，且己方本次战斗伤害大于0，满足条件则返回真。
	return d and d:IsControler(tp) and d:IsSetCard(0x135) and Duel.GetBattleDamage(tp)>0
end
-- ①效果的代价处理：先检查手卡的这张卡能否丢弃；若能，则将其从手卡丢弃作为发动代价。
function c14146794.damcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以“代价+丢弃”的理由送入墓地，即从手卡丢弃作为发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- ①效果处理：给己方玩家附加“避免战斗伤害”的字段效果，使本次战斗对自己的战斗伤害变成0，并在伤害步骤结束时重置。
function c14146794.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。②：「@火灵天星」怪兽或者「“艾”」魔法·陷阱卡的给与对方伤害的效果发动时，把墓地的这张卡除外才能发动（伤害步骤也能发动）。那个效果给与对方的伤害变成2倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将刚创建的“避免战斗伤害”效果注册给己方玩家，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件判定：当前连锁的效果为「@火灵天星」怪兽效果或「“艾”」魔法·陷阱卡效果，且该效果会给对方造成伤害。
function c14146794.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return ((re:GetHandler():IsSetCard(0x135) and re:IsActiveType(TYPE_MONSTER)) or (re:GetHandler():IsSetCard(0x136) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)))
		-- 调用 aux.damcon1 判定对方玩家（1-tp）会成为该效果伤害的对象，即满足“给与对方伤害”的条件。
		and aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp)
end
-- ②效果处理：记录当前连锁ID，给对方玩家附加“伤害变化”字段效果，使对应效果伤害翻倍，并在连锁处理结束后重置。
function c14146794.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁（被对应效果发动的那个连锁）的唯一ID，用于后续识别需要翻倍的是哪一次效果伤害。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果给与对方的伤害变成2倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetLabel(cid)
	e1:SetValue(c14146794.damval2)
	e1:SetReset(RESET_CHAIN)
	-- 将创建的“伤害变化”字段效果注册给己方玩家，使其生效。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害变化数值的计算函数：仅当来源为效果伤害且当前处理的连锁ID与记录一致时，将伤害值变为2倍，否则保持原伤害值。
function c14146794.damval2(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号，用于判断当前是否在连锁处理中。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的唯一ID，用于与之前记录的连锁ID比对，确认是否为需要翻倍的效果伤害。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel() and val*2 or val
end
