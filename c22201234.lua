--ライトロード・バリア
-- 效果：
-- 自己场上表侧表示存在的名字带有「光道」的怪兽成为攻击对象时，可以从自己卡组上面把2张卡送去墓地让1只对方怪兽的攻击无效。
function c22201234.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的名字带有「光道」的怪兽成为攻击对象时，可以从自己卡组上面把2张卡送去墓地让1只对方怪兽的攻击无效。
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
-- 效果发动条件判定：检查本次攻击对象是否为表侧表示、名字带有「光道」且由自己控制的怪兽。
function c22201234.qcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选为攻击对象的怪兽。
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsSetCard(0x38) and d:IsControler(tp)
end
-- 发动代价处理：从自己卡组上方将2张卡送去墓地，作为无效攻击的代价。
function c22201234.qcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认操作者能否把卡组上方2张卡送去墓地作为代价，不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 执行代价：实际将卡组上方2张卡送入墓地（原因设为REASON_COST）。
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 取对象目标选择：将发起攻击的对方怪兽作为该效果的对象，并确认其仍在场且可成为效果对象。
function c22201234.qtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前发动攻击的怪兽（攻击者）。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设定为当前连锁的效果对象，以便后续处理无效其攻击。
	Duel.SetTargetCard(tg)
end
-- 效果处理阶段：无效本次攻击。
function c22201234.qop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行攻击无效，使该攻击不成立（若此前已被无效则返回false，但此处直接调用）。
	Duel.NegateAttack()
end
