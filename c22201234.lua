--ライトロード・バリア
-- 效果：
-- 自己场上表侧表示存在的名字带有「光道」的怪兽成为攻击对象时，可以从自己卡组上面把2张卡送去墓地让1只对方怪兽的攻击无效。
function c22201234.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发即时效果，对应二速的【……才能发动】
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetDescription(aux.Stringid(22201234,1))  --"对方怪兽的攻击无效"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c22201234.qcon)
	e2:SetCost(c22201234.qcost)
	e2:SetTarget(c22201234.qtg)
	e2:SetOperation(c22201234.qop)
	c:RegisterEffect(e2)
end
-- 自己场上表侧表示存在的名字带有「光道」的怪兽成为攻击对象时
function c22201234.qcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中被选为攻击对象的怪兽
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsSetCard(0x38) and d:IsControler(tp)
end
-- 支付发动效果的代价，将自己卡组上面的2张卡送去墓地
function c22201234.qcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能作为Cost把2张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 将玩家卡组最上端2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 设置效果的对象为当前攻击怪兽
function c22201234.qtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取此次战斗中攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将目标怪兽设置为当前正在处理的连锁的对象
	Duel.SetTargetCard(tg)
end
-- 使1只对方怪兽的攻击无效
function c22201234.qop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
end
