--B・F－降魔弓のハマ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：同调怪兽为素材作同调召唤的这张卡在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡给与对方战斗伤害时才能发动。对方场上的全部怪兽的攻击力·守备力下降1000。
-- ③：对方没有受到战斗伤害的自己战斗阶段的结束时才能发动。给与对方为自己墓地的「蜂军」怪兽数量×300伤害。
function c80949182.initial_effect(c)
	-- 设置同调召唤的手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：同调怪兽为素材作同调召唤的这张卡
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c80949182.regcon)
	e0:SetOperation(c80949182.regop)
	c:RegisterEffect(e0)
	-- ①：同调怪兽为素材作同调召唤的这张卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c80949182.valcheck)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	-- 在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(c80949182.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡给与对方战斗伤害时才能发动。对方场上的全部怪兽的攻击力·守备力下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80949182,0))  --"攻击力·守备力下降"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1,80949182)
	e3:SetCondition(c80949182.atkcon)
	e3:SetTarget(c80949182.atktg)
	e3:SetOperation(c80949182.atkop)
	c:RegisterEffect(e3)
	-- ③：对方没有受到战斗伤害的自己战斗阶段的结束时才能发动。给与对方为自己墓地的「蜂军」怪兽数量×300伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80949182,1))  --"给与对方伤害"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,80949183)
	e4:SetCondition(c80949182.damcon)
	e4:SetTarget(c80949182.damtg)
	e4:SetOperation(c80949182.damop)
	c:RegisterEffect(e4)
	if not c80949182.global_check then
		c80949182.global_check=true
		c80949182[0]=-1
		c80949182[1]=-1
		-- ③：对方没有受到战斗伤害的自己战斗阶段的结束时才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetOperation(c80949182.checkop)
		-- 注册全局效果，用于记录玩家在当前回合受到战斗伤害时的回合数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查这张卡是否是通过同调召唤特殊召唤，且同调素材中包含同调怪兽。
function c80949182.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 为自身添加已使用同调怪兽作为素材进行同调召唤的标记（并显示提示信息）。
function c80949182.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(80949182,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(80949182,2))  --"同调怪兽为素材作同调召唤"
end
-- 检查同调素材中是否存在同调怪兽，并将结果（1或0）保存在e0效果的Label中。
function c80949182.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSynchroType,1,nil,TYPE_SYNCHRO) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查自身是否带有使用同调怪兽作为素材进行同调召唤的标记。
function c80949182.condition(e)
	return e:GetHandler():GetFlagEffect(80949182)>0
end
-- 确认造成战斗伤害的对象是对方玩家。
function c80949182.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤对方场上表侧表示、且攻击力或守备力大于0、且未被战斗破坏的怪兽。
function c80949182.atkfilter(c)
	return c:IsFaceup() and (c:IsAttackAbove(0) or c:IsDefenseAbove(0)) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②发动的靶向检测：对方场上必须存在至少1只满足条件的怪兽。
function c80949182.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以降低攻击力或守备力的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c80949182.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果②的实际处理：使对方场上所有符合条件的怪兽的攻击力和守备力下降1000。
function c80949182.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有符合条件的怪兽。
	local g=Duel.GetMatchingGroup(c80949182.atkfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力·守备力下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 效果③的发动条件：当前是自己的回合，且对方在此回合的战斗阶段中没有受到过战斗伤害。
function c80949182.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是自己的回合，且对方玩家最后一次受到战斗伤害的回合数小于当前回合数（即本回合未受过战斗伤害）。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()>c80949182[1-tp]
end
-- 过滤自己墓地的「蜂军」怪兽。
function c80949182.damfilter(c)
	return c:IsSetCard(0x12f) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动靶向与操作信息设置：确认自己墓地有「蜂军」怪兽，计算伤害值，并设置对方为伤害对象。
function c80949182.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只「蜂军」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c80949182.damfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 计算伤害值：自己墓地的「蜂军」怪兽数量乘以300。
	local val=Duel.GetMatchingGroupCount(c80949182.damfilter,tp,LOCATION_GRAVE,0,nil)*300
	-- 将效果处理的对象玩家设定为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果处理的伤害数值设定为计算出的伤害值。
	Duel.SetTargetParam(val)
	-- 设置连锁的操作信息为：给与对方玩家指定数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
-- 效果③的实际处理：获取目标玩家和最新计算的伤害值，并给与对方伤害。
function c80949182.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家（对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算效果处理时的伤害值（基于当前墓地的「蜂军」怪兽数量）。
	local val=Duel.GetMatchingGroupCount(c80949182.damfilter,tp,LOCATION_GRAVE,0,nil)*300
	-- 给与目标玩家由效果造成的伤害。
	Duel.Damage(p,val,REASON_EFFECT)
end
-- 全局伤害检测的处理函数：当有玩家受到战斗伤害时，记录该玩家受到伤害的当前回合数。
function c80949182.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 将受到战斗伤害的玩家最后一次受伤害的回合数更新为当前回合数。
	c80949182[ep]=Duel.GetTurnCount()
end
