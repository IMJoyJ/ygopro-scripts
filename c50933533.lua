--古代の機械巨竜
-- 效果：
-- ①：得到为这张卡的召唤而解放的怪兽的以下效果。
-- ●绿色零件：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ●红色零件：这张卡给与对方战斗伤害的场合发动。给与对方400伤害。
-- ●黄色零件：这张卡战斗破坏对方怪兽的场合发动。给与对方600伤害。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c50933533.initial_effect(c)
	-- 登记本卡效果文中提到的三种零件卡（绿色零件/红色零件/黄色零件）的卡号，供规则识别本卡记载的卡名。
	aux.AddCodeList(c,41172955,86445415,13839120)
	-- 对应①“得到为这张卡的召唤而解放的怪兽的以下效果。”：设置素材检查效果，用于在召唤时检查解放的怪兽种类并记录标志。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c50933533.valcheck)
	c:RegisterEffect(e1)
	-- 对应①“得到为这张卡的召唤而解放的怪兽的以下效果。”：在上级召唤成功时，根据素材检查记录的标志将对应效果注册给这张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c50933533.regcon)
	e2:SetOperation(c50933533.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
	-- 对应②“这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。”：创建限制对方不能发动魔法·陷阱卡的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c50933533.aclimit)
	e3:SetCondition(c50933533.actcon)
	c:RegisterEffect(e3)
end
-- 作为EFFECT_CANNOT_ACTIVATE的判定值，当对方发动的效果是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）时返回true，即禁止其发动。
function c50933533.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果发动条件：仅当当前攻击怪兽是这张卡本身时，该限制效果才适用。
function c50933533.actcon(e)
	-- 判定战斗阶段中的攻击怪兽是否为这张卡（e:GetHandler()），相等则条件成立。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 检查这张卡召唤时使用的素材（解放的怪兽），根据素材卡号设置标志位：0x1对应绿色零件、0x2对应红色零件、0x4对应黄色零件，并存入效果的Label。
function c50933533.valcheck(e,c)
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
-- 效果发动条件：这张卡是以上级召唤方式成功召唤的场合。
function c50933533.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 根据素材标志位为这张卡注册对应效果：0x1注册贯穿效果，0x2注册给与战斗伤害时造成400伤害的效果，0x4注册战斗破坏对方怪兽时造成600伤害的效果，并设置离场等重置。
function c50933533.regop(e,tp,eg,ep,ev,re,r,rp)
	local flag=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(flag,0x1)~=0 then
		-- 对应“●绿色零件：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。”：赋予这张卡贯穿伤害效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x2)~=0 then
		-- 对应“●红色零件：这张卡给与对方战斗伤害的场合发动。给与对方400伤害。”：注册触发效果，在给与对方战斗伤害时造成400点伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(50933533,0))  --"给予对方400伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCondition(c50933533.damcon1)
		e1:SetTarget(c50933533.damtg1)
		e1:SetOperation(c50933533.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if bit.band(flag,0x4)~=0 then
		-- 对应“●黄色零件：这张卡战斗破坏对方怪兽的场合发动。给与对方600伤害。”：注册触发效果，在战斗破坏对方怪兽时造成600点伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(50933533,1))  --"给予对方600伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetTarget(c50933533.damtg2)
		e1:SetOperation(c50933533.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 触发条件：受到战斗伤害的玩家（ep）不是这张卡的控制者（tp），即只有这张卡给与对方战斗伤害时才满足条件。
function c50933533.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 红色零件效果的发动时处理：不取对象，将伤害对象玩家设为对方，伤害值设为400，并向系统登记将造成400点效果伤害。
function c50933533.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp），表示伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的效果参数为400，即要造成的伤害数值。
	Duel.SetTargetParam(400)
	-- 向系统登记本次效果将造成400点效果伤害，对象为对方玩家，用于其他卡的效果检测和连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 黄色零件效果的发动时处理：不取对象，将伤害对象玩家设为对方，伤害值设为600，并向系统登记将造成600点效果伤害。
function c50933533.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家，表示伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的效果参数为600，即要造成的伤害数值。
	Duel.SetTargetParam(600)
	-- 向系统登记本次效果将造成600点效果伤害，对象为对方玩家，用于其他卡的效果检测和连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 共用伤害处理操作：从连锁信息中取出之前设定的对象玩家和伤害值，实际执行效果伤害。
function c50933533.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中记录的对象玩家p和参数值d，即伤害对象和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
