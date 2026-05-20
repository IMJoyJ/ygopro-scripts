--エーリアン・サイコ
-- 效果：
-- 这张卡召唤·反转召唤成功的场合变成守备表示。只要这张卡在场上表侧表示存在，放置有A指示物的怪兽不能攻击宣言。
function c58012107.initial_effect(c)
	-- 这张卡召唤成功的场合变成守备表示。
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
-- 召唤成功时改变表示形式效果的Target函数，确认自身是否为攻击表示并设置操作信息
function c58012107.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置改变自身表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 召唤成功时改变表示形式效果的Operation函数，若自身仍表侧攻击表示存在则转为表侧守备表示
function c58012107.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将自身变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤出放置有A指示物的怪兽
function c58012107.atktg(e,c)
	return c:GetCounter(0x100e)>0
end
