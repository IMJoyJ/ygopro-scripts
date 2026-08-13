--クラウソラスの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡不用仪式召唤不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「影灵衣」魔法·陷阱卡加入手卡。
-- ②：自己·对方回合，以从额外卡组特殊召唤的场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。
function c99185129.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤条件的效果值为aux.ritlimit，即只能用仪式召唤这种方式特殊召唤。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「影灵衣」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99185129,0))  --"效果无效"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,99185129)
	e2:SetCost(c99185129.thcost)
	e2:SetTarget(c99185129.thtg)
	e2:SetOperation(c99185129.thop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，以从额外卡组特殊召唤的场上1只表侧表示怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力变成0，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99185129,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,99185130)
	-- 设置发动条件为aux.dscon，即不能在伤害步骤内（伤害计算后）发动，只能在伤害计算前发动。
	e3:SetCondition(aux.dscon)
	e3:SetTarget(c99185129.target)
	e3:SetOperation(c99185129.operation)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价函数：检查这张卡能否从手卡丢弃，如果可以则将其丢弃作为代价。
function c99185129.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡送去墓地，作为发动代价（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义检索过滤条件：是「影灵衣」魔法·陷阱卡，且可以加入手卡。
function c99185129.thfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的目标函数：确认卡组存在符合条件的「影灵衣」魔法·陷阱卡，并设置操作信息。
function c99185129.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组是否存在至少1张符合条件的「影灵衣」魔法·陷阱卡，决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c99185129.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张「影灵衣」魔法·陷阱卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合条件的「影灵衣」魔法·陷阱卡加入手卡，并让对手确认。
function c99185129.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择卡片的提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张符合条件的「影灵衣」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c99185129.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡片加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果可选择对象：表侧表示、从额外卡组特殊召唤、攻击力大于0或效果未被无效的怪兽。
function c99185129.filter(c)
	-- 具体过滤条件：怪兽表侧表示、召唤位置为额外卡组，且攻击力>0或可以成为无效效果的对象。
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- ②效果的目标函数：选择场上1只满足条件的表侧表示怪兽作为对象。
function c99185129.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c99185129.filter(chkc) end
	-- 在发动时检查场上是否存在至少1只满足条件的对象。
	if chk==0 then return Duel.IsExistingTarget(c99185129.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择对象的提示：请选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只符合条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c99185129.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：使对象怪兽的攻击力变为0，并无效其效果，持续到回合结束。
function c99185129.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 将与对象怪兽相关的连锁效果无效化，持续到回合结束时。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
