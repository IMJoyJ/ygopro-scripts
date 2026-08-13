--スーパージュニア対決！
-- 效果：
-- 对方怪兽攻击宣言时发动。那个战斗无效，对方场上攻击力最低的1只表侧攻击表示怪兽和自己场上守备力最低的1只表侧守备表示怪兽进行战斗。那个战斗结束后，战斗阶段结束。
function c29590905.initial_effect(c)
	-- 对方怪兽攻击宣言时发动。那个战斗无效，对方场上攻击力最低的1只表侧攻击表示怪兽和自己场上守备力最低的1只表侧守备表示怪兽进行战斗。那个战斗结束后，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c29590905.condition)
	e1:SetTarget(c29590905.target)
	e1:SetOperation(c29590905.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：攻击宣言的怪兽是对方控制的怪兽时才满足发动条件。
function c29590905.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 效果发动时的合法性检查：确认自己场上存在至少1只表侧守备表示怪兽，以保证后续效果能够处理。
function c29590905.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查自己场上是否存在至少1只表侧守备表示怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_DEFENSE) end
end
-- 效果处理：分别获取对方场上的表侧攻击表示怪兽和自己场上的表侧守备表示怪兽，从中选出攻击力/守备力最低的怪兽（若有复数则由玩家选择），无效攻击宣言后令二者进行战斗，最后跳过对方战斗阶段。
function c29590905.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部表侧攻击表示怪兽的集合。
	local g1=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
	-- 获取自己场上全部表侧守备表示怪兽的集合。
	local g2=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	local ga=g1:GetMinGroup(Card.GetAttack)
	local gd=g2:GetMinGroup(Card.GetDefense)
	if ga:GetCount()>1 then
		-- 当攻击力最低的怪兽不只1只时，向当前玩家发送选择提示消息（请选择攻击力最低的1只怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29590905,0))  --"请选择攻击力最低的1只怪兽"
		ga=ga:Select(tp,1,1,nil)
	end
	if gd:GetCount()>1 then
		-- 当守备力最低的怪兽不只1只时，向当前玩家发送选择提示消息（请选择守备力最低的1只怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(29590905,1))  --"请选择守备力最低的1只怪兽"
		gd=gd:Select(tp,1,1,nil)
	end
	-- 无效这次攻击宣言，使原本的攻击被取消。
	Duel.NegateAttack()
	local a=ga:GetFirst()
	local d=gd:GetFirst()
	if a:IsAttackable() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then
		-- 令选出的对方攻击表示怪兽a与自己守备表示怪兽d进行战斗伤害计算（视为a攻击d）。
		Duel.CalculateDamage(a,d)
		-- 跳过对方玩家的战斗阶段（value=1表示跳过战斗阶段结束步骤），使整个战斗阶段结束。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
