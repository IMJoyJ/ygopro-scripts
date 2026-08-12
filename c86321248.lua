--古代の機械合成獣
-- 效果：
-- ①：得到为这张卡的召唤而解放的怪兽的以下效果。
-- ●绿色零件：这张卡的攻击力上升300。
-- ●红色零件：这张卡直接攻击给与对方战斗伤害的场合发动。给与对方500伤害。
-- ●黄色零件：这张卡战斗破坏对方怪兽的场合发动。给与对方700伤害。
function c86321248.initial_effect(c)
	-- 在卡片中记录「绿色零件」、「红色零件」、「黄色零件」的卡名，用于支持相关卡片的检索或关联判定
	aux.AddCodeList(c,41172955,86445415,13839120)
	-- ①：得到为这张卡的召唤而解放的怪兽的以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c86321248.valcheck)
	c:RegisterEffect(e1)
	-- ①：得到为这张卡的召唤而解放的怪兽的以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c86321248.regcon)
	e2:SetOperation(c86321248.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 检查召唤此卡时所使用的解放素材，并根据素材是否包含对应的零件怪兽来记录标记值
function c86321248.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetCode()
		if code==41172955 then flag=bit.bor(flag,0x1)
		elseif code==86445415 then flag=bit.bor(flag,0x2)
		elseif code==13839120 then flag=bit.bor(flag,0x4)
		end
		tc=g:GetNext()
	end
	e:SetLabel(flag)
end
-- 检查此卡是否是通过上级召唤（通常召唤）成功
function c86321248.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据解放素材的标记值，为这张卡注册并赋予对应的零件怪兽效果
function c86321248.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(flag,0x1)~=0 then
		-- ●绿色零件：这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		-- ●红色零件：这张卡直接攻击给与对方战斗伤害的场合发动。给与对方500伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(86321248,0))  --"给予对方500伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCondition(c86321248.damcon1)
		e1:SetTarget(c86321248.damtg1)
		e1:SetOperation(c86321248.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x4)~=0 then
		-- ●黄色零件：这张卡战斗破坏对方怪兽的场合发动。给与对方700伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(86321248,1))  --"给予对方700伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetTarget(c86321248.damtg2)
		e1:SetOperation(c86321248.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 检查是否是对方玩家受到战斗伤害，且当时没有攻击对象（即直接攻击）
function c86321248.damcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 确认受到战斗伤害的是对方玩家，且当时没有攻击目标（代表是直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 红色零件效果的发动准备，设置效果的对象玩家为对方，伤害数值为500
function c86321248.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害值）设置为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为：对对方玩家造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 黄色零件效果的发动准备，设置效果的对象玩家为对方，伤害数值为700
function c86321248.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害值）设置为700
	Duel.SetTargetParam(700)
	-- 设置当前连锁的操作信息为：对对方玩家造成700点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
-- 伤害效果的具体处理，获取预设的目标玩家和伤害数值并执行伤害
function c86321248.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式，给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
