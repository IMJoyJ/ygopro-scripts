--ブレイブアイズ・ペンデュラム・ドラゴン
-- 效果：
-- 「灵摆龙」怪兽＋战士族怪兽
-- ①：这张卡融合召唤成功时才能发动。对方场上的全部怪兽的攻击力变成0。这个回合，这张卡以外的自己怪兽不能攻击。
-- ②：只要这张卡在怪兽区域存在，攻击力0的怪兽发动的效果无效化。
-- ③：这张卡的攻击没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。
function c88305705.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「灵摆龙」怪兽和战士族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f2),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	-- ①：这张卡融合召唤成功时才能发动。对方场上的全部怪兽的攻击力变成0。这个回合，这张卡以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88305705,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c88305705.atkcon)
	e1:SetTarget(c88305705.atktg)
	e1:SetOperation(c88305705.atkop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，攻击力0的怪兽发动的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c88305705.discon)
	e2:SetOperation(c88305705.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击没让对方怪兽被破坏的伤害步骤结束时才能发动。那只对方怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88305705,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c88305705.rmcon)
	e3:SetTarget(c88305705.rmtg)
	e3:SetOperation(c88305705.rmop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否通过融合召唤特殊召唤
function c88305705.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤对方场上表侧表示且攻击力大于0的怪兽
function c88305705.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果①的发动准备与可行性检查
function c88305705.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力大于0的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88305705.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果①的处理：将对方场上所有怪兽的攻击力变成0，并限制本回合自身以外的自己怪兽不能攻击
function c88305705.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示且攻击力大于0的怪兽组
	local g=Duel.GetMatchingGroup(c88305705.atkfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个回合，这张卡以外的自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c88305705.ftarget)
	e2:SetLabel(c:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制本回合自己其他怪兽的攻击
	Duel.RegisterEffect(e2,tp)
end
-- 过滤出除这张卡以外的自己场上的怪兽
function c88305705.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果②的触发条件：检查发动的怪兽效果是否由攻击力为0的怪兽发动
function c88305705.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 获取触发效果的怪兽在发动效果时的攻击力
	local atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTACK)
	return re:IsActiveType(TYPE_MONSTER) and atk==0
end
-- 效果②的处理：使该怪兽效果的发动无效
function c88305705.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 效果③的触发条件：检查是否为这张卡进行攻击且对方怪兽未被战斗破坏的伤害步骤结束时
function c88305705.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	-- 检查伤害步骤结束时，这张卡是否作为攻击方进行了战斗且对方怪兽未被破坏
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and c==Duel.GetAttacker() and c:IsStatus(STATUS_OPPO_BATTLE)
		and bc and bc:IsOnField() and bc:IsRelateToBattle()
end
-- 效果③的发动准备：检查战斗对象是否可以被除外，并设置除外操作信息
function c88305705.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():IsAbleToRemove() end
	-- 设置效果处理信息，准备将1张目标怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
-- 效果③的处理：将未被破坏的对方战斗怪兽除外
function c88305705.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 将对方战斗怪兽表侧表示除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end
