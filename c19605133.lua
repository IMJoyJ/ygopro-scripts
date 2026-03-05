--ナチュル・レディバグ
-- 效果：
-- 自己对名字带有「自然」的同调怪兽的同调召唤成功时，自己墓地存在的这张卡可以在自己场上特殊召唤。此外，自己的主要阶段时把这张卡解放，选择自己场上表侧表示存在的1只名字带有「自然」的怪兽才能发动。选择的怪兽的攻击力直到这个回合的结束阶段时上升1000。
function c19605133.initial_effect(c)
	-- 自己对名字带有「自然」的同调怪兽的同调召唤成功时，自己墓地存在的这张卡可以在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19605133,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c19605133.spcon)
	e1:SetTarget(c19605133.sptg)
	e1:SetOperation(c19605133.spop)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时把这张卡解放，选择自己场上表侧表示存在的1只名字带有「自然」的怪兽才能发动。选择的怪兽的攻击力直到这个回合的结束阶段时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19605133,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c19605133.atcost)
	e2:SetTarget(c19605133.attg)
	e2:SetOperation(c19605133.atop)
	c:RegisterEffect(e2)
end
-- 检测触发效果的条件：确认被特殊召唤的怪兽是名字带有「自然」的同调怪兽且是自己召唤的。
function c19605133.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ec:IsSetCard(0x2a) and ec:IsSummonType(SUMMON_TYPE_SYNCHRO) and ec:IsSummonPlayer(tp)
end
-- 设置特殊召唤的条件：确认场上是否有足够的空间，并且该卡可以被特殊召唤。
function c19605133.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将该卡设置为即将特殊召唤的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作：如果该卡有效且满足条件，则将其特殊召唤到场上。
function c19605133.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行特殊召唤动作：将该卡以正面表示的形式特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置攻击上升效果的费用：可以选择支付2张手牌或解放自身作为费用。
function c19605133.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否受到效果影响，用于判断是否可以使用特定的费用支付方式。
	local fe=Duel.IsPlayerAffectedByEffect(tp,29942771)
	-- 判断是否可以支付2张手牌作为费用。
	local b1=fe and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
	local b2=c:IsReleasable()
	if chk==0 then return b1 or b2 end
	-- 如果可以支付2张手牌费用，则选择使用该方式支付。
	if b1 and (not b2 or Duel.SelectYesNo(tp,fe:GetDescription())) then
		-- 提示对方玩家使用了特定卡牌效果。
		Duel.Hint(HINT_CARD,0,29942771)
		fe:UseCountLimit(tp)
		-- 将玩家的2张卡从卡组送去墓地作为费用。
		Duel.DiscardDeck(tp,2,REASON_COST)
	else
		-- 解放自身作为费用。
		Duel.Release(c,REASON_COST)
	end
end
-- 过滤函数：筛选场上正面表示且名字带有「自然」的怪兽。
function c19605133.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 设置攻击上升效果的目标选择：选择场上正面表示的1只名字带有「自然」的怪兽。
function c19605133.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c19605133.filter(chkc) end
	-- 检查场上是否存在符合条件的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c19605133.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为目标。
	local g=Duel.SelectTarget(tp,c19605133.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行攻击上升效果：给目标怪兽增加1000攻击力直到回合结束。
function c19605133.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个攻击力增加1000的效果，并在回合结束时自动消失。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
