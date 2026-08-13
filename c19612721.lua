--円盤闘士
-- 效果：
-- 这张卡对守备力2000以上的守备表示怪兽进行攻击时，不经过损伤计算而直接将其破坏。
function c19612721.initial_effect(c)
	-- 这张卡对守备力2000以上的守备表示怪兽进行攻击时，不经过损伤计算而直接将其破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19612721,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetTarget(c19612721.destg)
	e1:SetOperation(c19612721.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件的判定：确认本卡为攻击者、攻击对象存在且为守备表示、守备力在2000以上；满足条件时设置破坏该攻击对象的操作信息。
function c19612721.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击对象。
	local t=Duel.GetAttackTarget()
	-- 判定攻击者为本卡、攻击对象存在且为守备表示、守备力在2000以上，满足则效果可发动。
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil and t:IsDefensePos() and t:IsDefenseAbove(2000) end
	-- 设置将攻击对象破坏的操作信息，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,t,1,0,0)
end
-- 效果处理：若攻击对象仍与本次战斗相关且不是攻击表示，则将其破坏。
function c19612721.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象。
	local t=Duel.GetAttackTarget()
	if t~=nil and t:IsRelateToBattle() and not t:IsAttackPos() then
		-- 以效果原因将攻击对象破坏。
		Duel.Destroy(t,REASON_EFFECT)
	end
end
