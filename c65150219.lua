--機甲忍法フリーズ・ロック
-- 效果：
-- 自己场上有名字带有「忍者」的怪兽存在的场合，对方怪兽的攻击宣言时才能把盖放的这张卡发动。那次攻击无效，战斗阶段结束。此外，只要自己场上有这张卡和名字带有「忍者」的怪兽存在，对方场上的全部怪兽不能把表示形式变更。
function c65150219.initial_effect(c)
	-- 自己场上有名字带有「忍者」的怪兽存在的场合，对方怪兽的攻击宣言时才能把盖放的这张卡发动。那次攻击无效，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c65150219.condition)
	e1:SetOperation(c65150219.activate)
	c:RegisterEffect(e1)
	-- 此外，只要自己场上有这张卡和名字带有「忍者」的怪兽存在，对方场上的全部怪兽不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c65150219.poscon)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「忍者」怪兽
function c65150219.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 发动条件：对方怪兽攻击宣言时，且自己场上有「忍者」怪兽存在
function c65150219.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合（对方攻击宣言），且自己场上是否存在表侧表示的「忍者」怪兽
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(c65150219.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的效果处理：无效攻击并结束战斗阶段
function c65150219.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效该次攻击
	if Duel.NegateAttack() then
		-- 跳过对方的战斗阶段（使其直接进入战斗阶段结束步骤）
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 不能变更表示形式效果的适用条件：自己场上有「忍者」怪兽存在
function c65150219.poscon(e)
	-- 检查自己场上是否存在表侧表示的「忍者」怪兽
	return Duel.IsExistingMatchingCard(c65150219.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
