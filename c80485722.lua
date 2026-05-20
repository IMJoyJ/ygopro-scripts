--ヴァンパイア・キラー
-- 效果：
-- 这张卡和暗属性怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c80485722.initial_effect(c)
	-- 这张卡和暗属性怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80485722,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c80485722.destg)
	e1:SetOperation(c80485722.desop)
	c:RegisterEffect(e1)
end
-- 在伤害步骤开始时，确认与此卡进行战斗的怪兽是否为表侧表示的暗属性怪兽，并设置破坏该怪兽的操作信息
function c80485722.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsFaceup() and bc:IsAttribute(ATTRIBUTE_DARK) end
	-- 设置将该战斗怪兽破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 在效果处理时，如果该战斗怪兽仍与本次战斗关联，则将其破坏
function c80485722.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将该战斗怪兽因效果破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
