--ゼロ・フォース
-- 效果：
-- 自己场上表侧表示存在的怪兽从游戏中除外时才能发动。场上表侧表示存在的全部怪兽的攻击力变成0。
function c17521642.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽从游戏中除外时才能发动。场上表侧表示存在的全部怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c17521642.condition)
	e1:SetTarget(c17521642.target)
	e1:SetOperation(c17521642.operation)
	c:RegisterEffect(e1)
end
-- 用于判定被除外的怪兽是否为“自己场上表侧表示存在的怪兽”：该怪兽之前的控制者是本玩家、当前控制者也为本玩家，之前位于怪兽区域且之前是表侧表示。
function c17521642.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 发动条件：在本次除外的怪兽中存在至少1只满足自己场上表侧表示怪兽条件的卡时，效果允许发动。
function c17521642.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17521642.cfilter,1,nil,tp)
end
-- 筛选场上表侧表示且攻击力大于0的怪兽，用于判断是否存在可被影响的对象。
function c17521642.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果发动时的合法性判定：若场上存在至少1只表侧表示且攻击力大于0的怪兽则满足发动条件（本效果不取对象）。
function c17521642.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时确认场上是否存在至少1只符合条件的表侧表示怪兽，存在则返回真，允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17521642.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理：获取场上全部表侧表示怪兽，逐只赋予“攻击力变为0”的单体效果，并在标准重置时机前持续生效。
function c17521642.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上所有表侧表示怪兽作为攻击力变为0的对象集合（不取对象，处理时选定）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上表侧表示存在的全部怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
