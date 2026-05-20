--雲魔物－ポイズン・クラウド
-- 效果：
-- 场上表侧表示存在的这张卡被战斗破坏送去墓地时，把让这张卡破坏的怪兽破坏并给与对方基本分800分伤害。
function c83982270.initial_effect(c)
	-- 场上表侧表示存在的这张卡被战斗破坏送去墓地时，把让这张卡破坏的怪兽破坏并给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83982270,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c83982270.condition)
	e1:SetTarget(c83982270.target)
	e1:SetOperation(c83982270.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否在墓地、是否因战斗破坏、且在场上时是否为表侧表示
function c83982270.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 设置效果发动的操作信息，由于是必发效果，直接返回true
function c83982270.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏的操作信息，目标为与自身进行战斗的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
	-- 设置伤害的操作信息，给与对方玩家800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理，尝试破坏与自身进行战斗的怪兽，若成功则给与对方800点伤害
function c83982270.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查战斗对手怪兽是否表侧表示存在且与本次战斗关联，并将其用效果破坏
	if bc:IsFaceup() and bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)~=0 then
		-- 给与对方玩家800点效果伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
