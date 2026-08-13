--邪悪なるバリア －ダーク・フォース－
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。对方场上守备表示存在的怪兽全部从游戏中除外。
function c20522190.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。对方场上守备表示存在的怪兽全部从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c20522190.condition)
	e1:SetTarget(c20522190.target)
	e1:SetOperation(c20522190.activate)
	c:RegisterEffect(e1)
end
-- 发动条件函数：判定当前是否为对方回合（即对方怪兽进行攻击宣言时），只有在自己不是回合玩家的情况下才满足发动条件。
function c20522190.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“本卡发动者不是当前回合玩家”，确保效果只能在对方回合（对方怪兽攻击宣言时）发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数：筛选对方场上守备表示且可以被除外的怪兽。
function c20522190.filter(c)
	return c:IsDefensePos() and c:IsAbleToRemove()
end
-- 发动时的目标处理：检查对方场上是否存在符合条件的怪兽，若有则将对方场上所有守备表示且可除外的怪兽作为本次效果将要除外的对象，并设置操作信息。
function c20522190.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：确认对方场地上存在至少1只满足“守备表示且可除外”条件的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20522190.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足“守备表示且可除外”条件的怪兽，作为待除外对象。
	local g=Duel.GetMatchingGroup(c20522190.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理时的操作信息：将上述怪兽组g标记为除外对象，数量为g:GetCount()，用于后续发动检测和连锁处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理函数：在效果结算时重新获取对方场上所有符合条件的怪兽，若存在则将其全部除外。
function c20522190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取对方场上当前所有满足“守备表示且可除外”条件的怪兽，确保按实际场上情况处理。
	local g=Duel.GetMatchingGroup(c20522190.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将符合条件的对方怪兽以表侧表示从游戏中除外，除外原因为效果（REASON_EFFECT）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
