--ジュラック・ヴェルヒプト
-- 效果：
-- 调整＋调整以外的恐龙族怪兽1只以上
-- ①：这张卡的攻击力·守备力变成作为这张卡的同调素材的怪兽的原本攻击力合计数值。
-- ②：这张卡向里侧守备表示怪兽攻击的伤害步骤开始时才能发动。那只里侧守备表示怪兽破坏。
function c65961683.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的恐龙族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DINOSAUR),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力变成作为这张卡的同调素材的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c65961683.matcheck)
	c:RegisterEffect(e1)
	-- ②：这张卡向里侧守备表示怪兽攻击的伤害步骤开始时才能发动。那只里侧守备表示怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65961683,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c65961683.descon)
	e2:SetTarget(c65961683.destg)
	e2:SetOperation(c65961683.desop)
	c:RegisterEffect(e2)
end
-- 同调素材检查函数，用于获取同调素材的原本攻击力合计并设置这张卡的攻击力与守备力
function c65961683.matcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	while tc do
		local tatk=tc:GetBaseAttack()
		atk=atk+tatk
		tc=g:GetNext()
	end
	-- ①：这张卡的攻击力...变成作为这张卡的同调素材的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- 效果发动条件检查函数，判断是否在自身向里侧守备表示怪兽攻击的伤害步骤开始时
function c65961683.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 返回是否满足“自身是攻击怪兽且攻击目标是里侧守备表示怪兽”的条件
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsPosition(POS_FACEDOWN_DEFENSE)
end
-- 效果发动目标检查与操作信息设置函数
function c65961683.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查当前的攻击目标是否可以被效果破坏
	if chk==0 then return Duel.GetAttackTarget():IsDestructable() end
	-- 设置操作信息为破坏该攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理函数，将处于战斗关系中的攻击目标怪兽破坏
function c65961683.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 将该攻击目标怪兽因效果破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
