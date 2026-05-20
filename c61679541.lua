--BK ラビット・パンチャー
-- 效果：
-- 这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
function c61679541.initial_effect(c)
	-- 这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61679541,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c61679541.targ)
	e1:SetOperation(c61679541.op)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测：检查自身是否为攻击怪兽，且攻击目标存在、为守备表示并与本次战斗相关联
function c61679541.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击目标（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	-- 在检测阶段，检查攻击怪兽是否为这张卡自身
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d~=nil and d:IsDefensePos() and d:IsRelateToBattle() end
	-- 设置效果处理的操作信息，表示该效果会破坏1只作为攻击目标的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果处理：如果攻击目标存在、仍与战斗关联且为守备表示，则通过效果将其破坏
function c61679541.op(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取当前的攻击目标
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() and d:IsDefensePos() then
		-- 因效果原因破坏作为攻击目标的怪兽
		Duel.Destroy(d,REASON_EFFECT)
	end
end
