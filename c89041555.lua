--生贄の抱く爆弾
-- 效果：
-- ①：上级召唤的对方怪兽的攻击宣言时才能发动。对方场上的表侧攻击表示怪兽全部破坏，给与对方1000伤害。
function c89041555.initial_effect(c)
	-- ①：上级召唤的对方怪兽的攻击宣言时才能发动。对方场上的表侧攻击表示怪兽全部破坏，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c89041555.condition)
	e1:SetTarget(c89041555.target)
	e1:SetOperation(c89041555.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c89041555.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且宣告攻击的怪兽是否为上级召唤的怪兽
	return tp~=Duel.GetTurnPlayer() and eg:GetFirst():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤对方场上表侧攻击表示怪兽的条件函数
function c89041555.filter(c)
	return c:IsAttackPos()
end
-- 定义效果发动时的目标选择与操作信息设置函数
function c89041555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查对方场上是否存在至少1只表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89041555.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧攻击表示的怪兽组
	local g=Duel.GetMatchingGroup(c89041555.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害操作信息，给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 定义效果处理（发动效果）函数
function c89041555.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧攻击表示的怪兽组
	local g=Duel.GetMatchingGroup(c89041555.filter,tp,0,LOCATION_MZONE,nil)
	-- 若存在符合条件的怪兽，则将其全部破坏，并确认是否成功破坏了至少1只怪兽
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 给与对方玩家1000点效果伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
