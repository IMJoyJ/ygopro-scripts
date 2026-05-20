--レッド・デーモンズ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡向对方的守备表示怪兽进行攻击的伤害计算后发动。对方场上的守备表示怪兽全部破坏。
-- ②：自己结束阶段发动。这张卡在场上表侧表示存在的场合，这个回合没有攻击宣言的自己场上的其他怪兽全部破坏。
function c70902743.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡向对方的守备表示怪兽进行攻击的伤害计算后发动。对方场上的守备表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70902743,0))  --"守备怪物全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c70902743.condition1)
	e1:SetTarget(c70902743.target1)
	e1:SetOperation(c70902743.operation1)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。这张卡在场上表侧表示存在的场合，这个回合没有攻击宣言的自己场上的其他怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70902743,1))  --"未攻击的怪物全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c70902743.condition2)
	e2:SetTarget(c70902743.target2)
	e2:SetOperation(c70902743.operation2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：此卡向对方守备表示怪兽进行攻击的伤害计算后
function c70902743.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否为自身，且存在攻击对象，且该攻击对象为守备表示
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget() and not Duel.GetAttackTarget():IsAttackPos()
end
-- 过滤条件：守备表示的怪兽
function c70902743.filter1(c)
	return not c:IsAttackPos()
end
-- 效果①的发动准备：获取对方场上所有的守备表示怪兽，并设置破坏操作信息
function c70902743.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(c70902743.filter1,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的处理：破坏对方场上所有的守备表示怪兽
function c70902743.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的守备表示怪兽
	local g=Duel.GetMatchingGroup(c70902743.filter1,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏指定的怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤条件：本回合没有进行过攻击宣言的怪兽
function c70902743.filter2(c)
	return c:GetAttackAnnouncedCount()==0
end
-- 效果②的发动条件：自己的结束阶段
function c70902743.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 效果②的发动准备：获取自己场上除自身以外、本回合未进行攻击宣言的所有怪兽，并设置破坏操作信息
function c70902743.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上除自身以外、本回合未进行攻击宣言的所有怪兽
	local g=Duel.GetMatchingGroup(c70902743.filter2,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 设置破坏操作信息，包含要破坏的未攻击怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的处理：若此卡在场上表侧表示存在，则破坏自己场上除自身以外、本回合未进行攻击宣言的所有怪兽
function c70902743.operation2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取自己场上除自身（若仍在场上）以外、本回合未进行攻击宣言的所有怪兽
	local g=Duel.GetMatchingGroup(c70902743.filter2,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	-- 因效果破坏指定的怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end
