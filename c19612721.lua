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
-- 当此卡攻击守备表示且守备力2000以上的怪兽时，发动破坏效果
function c19612721.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击战斗中被攻击的怪兽
	local t=Duel.GetAttackTarget()
	-- 检查是否为攻击怪兽攻击守备表示且守备力2000以上的怪兽
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil and t:IsDefensePos() and t:IsDefenseAbove(2000) end
	-- 设置连锁操作信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,t,1,0,0)
end
-- 执行破坏效果
function c19612721.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击战斗中被攻击的怪兽
	local t=Duel.GetAttackTarget()
	if t~=nil and t:IsRelateToBattle() and not t:IsAttackPos() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(t,REASON_EFFECT)
	end
end
