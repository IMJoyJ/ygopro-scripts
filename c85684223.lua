--ナイトメアを駆る死霊
-- 效果：
-- 「削魂的死灵」＋「梦魇马」
-- 这张卡不会被战斗破坏。这张卡成为魔法·陷阱·效果怪兽效果的对象时，这张卡破坏。这张卡在对方场上存在怪兽的状态下也能对对方进行直接攻击。这张卡对对方进行直接攻击成功时，对方随机丢弃1张手卡。
function c85684223.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「削魂的死灵」和「梦魇马」的融合召唤手续
	aux.AddFusionProcCode2(c,23205979,59290628,true,true)
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡对对方进行直接攻击成功时，对方随机丢弃1张手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85684223,0))  --"丢弃手牌"
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c85684223.condition)
	e2:SetTarget(c85684223.target)
	e2:SetOperation(c85684223.operation)
	c:RegisterEffect(e2)
	-- 这张卡成为魔法·陷阱·效果怪兽效果的对象时，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(c85684223.sdcon)
	c:RegisterEffect(e3)
	-- 这张卡成为魔法·陷阱·效果怪兽效果的对象时，这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetOperation(c85684223.desop1)
	c:RegisterEffect(e4)
	-- 这张卡成为魔法·陷阱·效果怪兽效果的对象时，这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetOperation(c85684223.desop2)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
	-- 这张卡成为魔法·陷阱·效果怪兽效果的对象时，这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_BATTLED)
	e6:SetOperation(c85684223.desop3)
	e6:SetLabelObject(e4)
	c:RegisterEffect(e6)
	-- 这张卡在对方场上存在怪兽的状态下也能对对方进行直接攻击。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e7)
end
-- 直接攻击成功时丢弃对方手牌效果的发动条件：对对方造成战斗伤害且没有攻击目标怪兽
function c85684223.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方，且没有攻击目标怪兽（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 直接攻击成功时丢弃对方手牌效果的发动准备
function c85684223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为对方丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 直接攻击成功时丢弃对方手牌效果的实际处理
function c85684223.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到伤害的玩家（对方）的手牌
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的手牌以效果丢弃的方式送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-- 检查自身是否正成为效果的对象
function c85684223.sdcon(e)
	return e:GetHandler():GetOwnerTargetCount()>0
end
-- 当自身在怪兽区表侧表示存在并成为效果对象时，记录该效果并初始化延迟破坏标记
function c85684223.desop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		e:SetLabelObject(re)
		e:SetLabel(0)
	end
end
-- 在连锁处理结束时，若自身仍与该效果相关，则根据时点决定是延迟破坏还是直接破坏自身
function c85684223.desop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re==e:GetLabelObject():GetLabelObject() and c:IsRelateToEffect(re) then
		-- 判断当前是否处于伤害步骤且尚未进行伤害计算
		if Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
			e:GetLabelObject():SetLabel(1)
		else
			-- 若自身效果未被无效，则因效果破坏自身
			if not c:IsDisabled() then Duel.Destroy(c,REASON_EFFECT) end
		end
	end
end
-- 在伤害计算后，若存在延迟破坏标记且自身效果未被无效，则破坏自身
function c85684223.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local des=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	if des==1 and not c:IsDisabled() then
		-- 因效果破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
