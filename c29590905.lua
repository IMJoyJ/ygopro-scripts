--スーパージュニア対決！
-- 效果：
-- 对方怪兽攻击宣言时发动。那个战斗无效，对方场上攻击力最低的1只表侧攻击表示怪兽和自己场上守备力最低的1只表侧守备表示怪兽进行战斗。那个战斗结束后，战斗阶段结束。
function c29590905.initial_effect(c)
	-- 创建效果，设置为魔陷发动时的效果，触发条件为对方怪兽攻击宣言时，目标为己方场上表侧守备表示怪兽，发动时执行activate函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c29590905.condition)
	e1:SetTarget(c29590905.target)
	e1:SetOperation(c29590905.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：确认攻击方是否为对方
function c29590905.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 效果目标：确认己方场上是否存在至少1只表侧守备表示怪兽
function c29590905.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若chk为0（未确认阶段），则检查己方场上是否存在至少1只表侧守备表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_DEFENSE) end
end
-- 效果发动：检索己方场上所有表侧攻击表示怪兽和表侧守备表示怪兽，若存在多只攻击力/守备力最低的怪兽则进行选择，然后无效攻击并令其进行战斗，最后跳过战斗阶段
function c29590905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上所有表侧攻击表示怪兽组成的组
	local g1=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
	-- 获取己方场上所有表侧守备表示怪兽组成的组
	local g2=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	local ga=g1:GetMinGroup(Card.GetAttack)
	local gd=g2:GetMinGroup(Card.GetDefense)
	if ga:GetCount()>1 then
		-- 提示玩家选择攻击力最低的1只怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29590905,0))  --"请选择攻击力最低的1只怪兽"
		ga=ga:Select(tp,1,1,nil)
	end
	if gd:GetCount()>1 then
		-- 提示玩家选择守备力最低的1只怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29590905,1))  --"请选择守备力最低的1只怪兽"
		gd=gd:Select(tp,1,1,nil)
	end
	-- 无效此次攻击
	Duel.NegateAttack()
	local a=ga:GetFirst()
	local d=gd:GetFirst()
	if a:IsAttackable() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then
		-- 令攻击怪兽与防守怪兽进行战斗伤害计算
		Duel.CalculateDamage(a,d)
		-- 跳过对方的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
