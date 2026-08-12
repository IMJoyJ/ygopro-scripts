--N・グラン・モール
-- 效果：
-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽和这张卡回到持有者手卡。
function c80344569.initial_effect(c)
	-- ①：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽和这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80344569,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c80344569.target)
	e1:SetOperation(c80344569.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测函数
function c80344569.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段（chk==0）检查自身是否在与对方怪兽进行战斗（自身是被攻击怪兽，或者自身是攻击怪兽且存在攻击对象）
	if chk==0 then return Duel.GetAttackTarget()==c or (Duel.GetAttacker()==c and Duel.GetAttackTarget()~=nil) end
	-- 将进行战斗的双方怪兽（攻击怪兽和防守怪兽）放入一个卡片组中
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	-- 设置操作信息，表示该效果会将战斗的双方怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数
function c80344569.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 获取本次战斗的攻击怪兽
	local c=Duel.GetAttacker()
	if c:IsRelateToBattle() then g:AddCard(c) end
	-- 获取本次战斗的攻击目标（防守怪兽）
	c=Duel.GetAttackTarget()
	if c~=nil and c:IsRelateToBattle() then g:AddCard(c) end
	if g:GetCount()>0 then
		-- 通过效果将依然存在于战斗中的怪兽送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
