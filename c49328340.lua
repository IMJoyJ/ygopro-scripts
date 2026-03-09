--螺旋槍殺
-- 效果：
-- ①：自己的「暗黑骑士 盖亚」「疾风之暗黑骑士 盖亚」「龙骑士 盖亚」向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡的①的效果适用让「龙骑士 盖亚」给与对方战斗伤害的场合发动。自己从卡组抽2张，那之后选1张手卡丢弃。
function c49328340.initial_effect(c)
	-- 记录该卡牌效果适用于「暗黑骑士 盖亚」「疾风之暗黑骑士 盖亚」「龙骑士 盖亚」三张卡片
	aux.AddCodeList(c,6368038,16589042,66889139)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的「暗黑骑士 盖亚」「疾风之暗黑骑士 盖亚」「龙骑士 盖亚」向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c49328340.pietg)
	c:RegisterEffect(e2)
	-- ②：这张卡的①的效果适用让「龙骑士 盖亚」给与对方战斗伤害的场合发动。自己从卡组抽2张，那之后选1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49328340,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c49328340.condition)
	e3:SetTarget(c49328340.target)
	e3:SetOperation(c49328340.operation)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为指定的三张盖亚系列怪兽之一
function c49328340.pietg(e,c)
	return c:IsCode(6368038,16589042,66889139)
end
-- 判断攻击方是否为己方控制、防守方存在且处于守备表示、攻击方是否为龙骑士 盖亚
function c49328340.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsControler(tp) and bc and bc:IsDefensePos() and tc:IsCode(66889139)
end
-- 设置连锁处理时的抽卡与丢弃手牌操作信息
function c49328340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要进行2张卡的抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置将要进行1张手牌的丢弃操作
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 执行效果发动后的抽卡与丢弃手牌操作
function c49328340.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍在场上且己方卡组有卡可抽
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 执行从卡组抽取2张卡的操作
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		-- 将己方手牌洗切
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 丢弃一张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
