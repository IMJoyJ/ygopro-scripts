--雲魔物－アイ・オブ・ザ・タイフーン
-- 效果：
-- 这张卡不会被战斗破坏。这张卡表侧守备表示在场上存在的场合，这张卡破坏。这张卡的攻击宣言时，把名字带有「云魔物」的卡以外的全部表侧表示怪兽的表示形式改变。
function c57610714.initial_effect(c)
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡表侧守备表示在场上存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c57610714.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡的攻击宣言时，把名字带有「云魔物」的卡以外的全部表侧表示怪兽的表示形式改变。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57610714,0))  --"改变表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetOperation(c57610714.posop)
	c:RegisterEffect(e3)
end
-- 检查自身是否处于表侧守备表示，作为自我破坏效果的适用条件
function c57610714.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤场上表侧表示且卡名不含有「云魔物」的怪兽
function c57610714.filter(c)
	return c:IsFaceup() and not c:IsSetCard(0x18)
end
-- 攻击宣言时的效果处理：获取场上所有非「云魔物」的表侧表示怪兽，并改变它们的表示形式
function c57610714.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足过滤条件（表侧表示且非「云魔物」）的怪兽组
	local g=Duel.GetMatchingGroup(c57610714.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 改变目标怪兽组的表示形式（表侧攻击表示与表侧守备表示互相转换）
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
