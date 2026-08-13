--エーリアン・サイコ
-- 效果：
-- 这张卡召唤·反转召唤成功的场合变成守备表示。只要这张卡在场上表侧表示存在，放置有A指示物的怪兽不能攻击宣言。
function c58012107.initial_effect(c)
	-- 这张卡召唤·反转召唤成功的场合变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58012107,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c58012107.potg)
	e1:SetOperation(c58012107.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，放置有A指示物的怪兽不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetTarget(c58012107.atktg)
	c:RegisterEffect(e3)
end
c58012107.mentioned_counter={
	[0x100e]=true,
}
-- 检查这张卡是否为攻击表示，若是则把改变表示形式的操作信息登记到连锁中。
function c58012107.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置本次效果处理的操作信息：对这张卡自身进行1次表示形式变更。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍为表侧攻击表示且与该效果保持联系，则将其变为守备表示。
function c58012107.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判断目标怪兽上是否放置有A指示物，有则该怪兽不能攻击宣言。
function c58012107.atktg(e,c)
	return c:GetCounter(0x100e)>0
end
