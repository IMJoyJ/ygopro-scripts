--E-HERO ダーク・ガイア
-- 效果：
-- 恶魔族怪兽＋岩石族怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡的原本攻击力变成作为这张卡的融合素材的怪兽的原本攻击力合计数值。
-- ②：这张卡的攻击宣言时才能发动。对方场上的守备表示怪兽全部变成表侧攻击表示。这个时候，反转怪兽的效果不发动。
function c58332301.initial_effect(c)
	-- 将「暗黑融合」卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为恶魔族怪兽和岩石族怪兽各1只
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的限制函数，使其只能通过「暗黑融合」等相关效果特殊召唤
	e2:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e2)
	-- ①：这张卡的原本攻击力变成作为这张卡的融合素材的怪兽的原本攻击力合计数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(c58332301.matcheck)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击宣言时才能发动。对方场上的守备表示怪兽全部变成表侧攻击表示。这个时候，反转怪兽的效果不发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetDescription(aux.Stringid(58332301,0))  --"改变表示形式"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c58332301.postg)
	e3:SetOperation(c58332301.posop)
	c:RegisterEffect(e3)
end
c58332301.dark_calling=true
-- 融合素材检查函数，用于计算融合素材怪兽的原本攻击力合计值并将其设为这张卡的原本攻击力
function c58332301.matcheck(e,c)
	local g=c:GetMaterial()
	local s=0
	local tc=g:GetFirst()
	while tc do
		local a=tc:GetBaseAttack()
		s=s+a
		tc=g:GetNext()
	end
	-- 这张卡的原本攻击力变成作为这张卡的融合素材的怪兽的原本攻击力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(s)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 攻击宣言时发动效果的Target函数，检查对方场上是否存在守备表示怪兽并设置改变表示形式的操作信息
function c58332301.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查对方场上是否存在至少1只守备表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，表明该效果的处理涉及改变上述怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 攻击宣言时发动效果的Operation函数，将对方场上的守备表示怪兽全部变成表侧攻击表示，且不触发反转效果
function c58332301.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取对方场上当前所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
	-- 将获取到的怪兽全部改变为表侧攻击表示，并设置不触发反转效果
	Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
end
