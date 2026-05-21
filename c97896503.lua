--ズババナイト
-- 效果：
-- ①：这张卡向表侧守备表示怪兽攻击的伤害步骤开始时发动。那只怪兽破坏。
function c97896503.initial_effect(c)
	-- ①：这张卡向表侧守备表示怪兽攻击的伤害步骤开始时发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97896503,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c97896503.tg)
	e1:SetOperation(c97896503.op)
	c:RegisterEffect(e1)
end
-- 在发动阶段检查此卡是否为攻击怪兽，且攻击目标是否存在并处于表侧守备表示
function c97896503.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 在发动条件检查时，确认当前进行攻击的怪兽是否是此卡自身
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d~=nil and d:IsPosition(POS_FACEUP_DEFENSE) end
	-- 设置效果处理信息，声明此效果的操作为破坏1个攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果处理：若攻击目标怪兽存在、仍处于战斗中且为守备表示，则将其破坏
function c97896503.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d~=nil and d:IsRelateToBattle() and d:IsDefensePos() then
		-- 因效果将该攻击目标怪兽破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
