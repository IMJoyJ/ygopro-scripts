--邪悪なるバリア －ダーク・フォース－
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。对方场上守备表示存在的怪兽全部从游戏中除外。
function c20522190.initial_effect(c)
	-- 效果原文内容：对方怪兽的攻击宣言时才能发动。对方场上守备表示存在的怪兽全部从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c20522190.condition)
	e1:SetTarget(c20522190.target)
	e1:SetOperation(c20522190.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方的攻击宣言阶段
function c20522190.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：当前玩家不是攻击方时才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 效果作用：定义过滤函数，用于筛选对方场上守备表示且可除外的怪兽
function c20522190.filter(c)
	return c:IsDefensePos() and c:IsAbleToRemove()
end
-- 效果作用：设置连锁处理的目标，确定要除外的怪兽组
function c20522190.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查对方场上是否存在至少1只守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c20522190.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取对方场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c20522190.filter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置操作信息，标记本次效果将要除外的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果作用：执行效果，将符合条件的怪兽从游戏中除外
function c20522190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：再次获取对方场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c20522190.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 效果作用：将怪兽以正面表示形式从游戏中除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
