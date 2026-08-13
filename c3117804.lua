--超重武者ビッグベン－K
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：只要这张卡在怪兽区域存在，自己的「超重武者」怪兽可以用表侧守备表示的状态作出攻击。那个场合，那怪兽用守备力当作攻击力使用进行伤害计算。
function c3117804.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3117804,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetOperation(c3117804.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的「超重武者」怪兽可以用表侧守备表示的状态作出攻击。那个场合，那怪兽用守备力当作攻击力使用进行伤害计算。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c3117804.atktg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果处理时：获取发动效果的这张卡，若它仍表侧表示且与本次发动保持关联，则变更其表示形式（表侧攻击与表侧守备互换，里侧表示不变）。
function c3117804.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式按规则变更：当前为表侧攻击表示则改为表侧守备表示，当前为表侧守备表示则改为表侧攻击表示；0表示里侧攻击/守备表示不改变。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 效果适用对象的筛选函数：只有满足「超重武者」字段（0x9a）的怪兽，才会被这张卡赋予“可用表侧守备表示攻击”的永续效果。
function c3117804.atktg(e,c)
	return c:IsSetCard(0x9a)
end
