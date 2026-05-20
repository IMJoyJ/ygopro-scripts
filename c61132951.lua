--H・C 夜襲のカンテラ
-- 效果：
-- 这张卡向对方场上守备表示存在的怪兽攻击的场合，伤害计算前可以把那只怪兽破坏。
function c61132951.initial_effect(c)
	-- 这张卡向对方场上守备表示存在的怪兽攻击的场合，伤害计算前可以把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61132951,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetTarget(c61132951.destg)
	e1:SetOperation(c61132951.desop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件与目标过滤：检查自身是否为攻击怪兽，且攻击目标是否存在、为守备表示并处于战斗状态
function c61132951.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击目标（被攻击的怪兽）
	local d=Duel.GetAttackTarget()
	-- 在进行发动条件检查时，确认当前攻击怪兽是否为这张卡自身
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d and d:IsDefensePos() and d:IsRelateToBattle() end
	-- 设置操作信息，声明此效果在处理时会破坏1张卡（即攻击目标）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 定义效果的处理：若攻击目标在效果处理时仍处于战斗状态且为守备表示，则将其破坏
function c61132951.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() and d:IsDefensePos() then
		-- 因效果将攻击目标怪兽破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
