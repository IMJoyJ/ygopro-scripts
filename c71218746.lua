--ドリルロイド
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的伤害计算前发动。那只怪兽破坏。
function c71218746.initial_effect(c)
	-- ①：这张卡向守备表示怪兽攻击的伤害计算前发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71218746,0))  --"破坏守备怪物"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetTarget(c71218746.targ)
	e1:SetOperation(c71218746.op)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标检测与操作信息设置函数
function c71218746.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击目标怪兽
	local t=Duel.GetAttackTarget()
	-- 在发动检测阶段，确认攻击怪兽是自身，且存在守备表示的攻击目标
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil and not t:IsAttackPos() end
	-- 设置效果处理信息，表示将要破坏1只攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,t,1,0,0)
end
-- 定义效果处理的执行函数，在伤害计算前将符合条件的守备表示怪兽破坏
function c71218746.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击目标怪兽
	local t=Duel.GetAttackTarget()
	if t~=nil and t:IsRelateToBattle() and not t:IsAttackPos() then
		-- 因效果将该攻击目标怪兽破坏
		Duel.Destroy(t,REASON_EFFECT)
	end
end
