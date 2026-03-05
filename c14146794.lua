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
	-- 将此卡从手卡丢弃作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c14146794.damop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断函数
function c14146794.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在攻击的怪兽
	local d=Duel.GetAttackTarget()
	-- 判断是否为我方控制的「@火灵天星」怪兽且本次战斗伤害大于0
	return d and d:IsControler(tp) and d:IsSetCard(0x135) and Duel.GetBattleDamage(tp)>0
end
-- 效果①的发动cost函数
function c14146794.damcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡送去墓地作为cost
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动效果处理函数
function c14146794.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个使玩家不受战斗伤害的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的发动条件判断函数
function c14146794.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return ((re:GetHandler():IsSetCard(0x135) and re:IsActiveType(TYPE_MONSTER)) or (re:GetHandler():IsSetCard(0x136) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)))
		-- 判断对方受到的伤害是否来自我方的「@火灵天星」怪兽或「“艾”」魔法·陷阱卡
		and aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp)
end
-- 效果②的发动效果处理函数
function c14146794.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 创建一个使伤害翻倍的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetLabel(cid)
	e1:SetValue(c14146794.damval2)
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 伤害值修改函数
function c14146794.damval2(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel() and val*2 or val
end
