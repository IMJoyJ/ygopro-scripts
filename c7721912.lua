--聖騎士の槍持ち
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己场上1只8星以下的怪兽为对象才能发动。那只怪兽直到结束阶段卡名当作「鲜花同调士」使用，当作调整使用。
-- ②：把这张卡解放才能发动。从卡组把1张装备魔法卡加入手卡。
function c7721912.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己场上1只8星以下的怪兽为对象才能发动。那只怪兽直到结束阶段卡名当作「鲜花同调士」使用，当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7721912,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,7721912)
	e1:SetTarget(c7721912.cntg)
	e1:SetOperation(c7721912.cnop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把这张卡解放才能发动。从卡组把1张装备魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7721912,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,7721913)
	e3:SetCost(c7721912.cost)
	e3:SetTarget(c7721912.target)
	e3:SetOperation(c7721912.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示、等级8以下，且不同时满足卡名为「鲜花同调士」且是调整怪兽的怪兽
function c7721912.cnfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and not (c:IsCode(19642774) and c:IsType(TYPE_TUNER))
end
-- 效果①的对象选择与发动准备函数
function c7721912.cntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7721912.cnfilter(chkc) end
	-- 在发动效果时，检查自己场上是否存在至少1只满足条件的8星以下怪兽
	if chk==0 then return Duel.IsExistingTarget(c7721912.cnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c7721912.cnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理函数，使作为对象的怪兽直到结束阶段卡名当作「鲜花同调士」使用，并当作调整使用
function c7721912.cnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到结束阶段卡名当作「鲜花同调士」使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(19642774)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e2)
	end
end
-- 效果②的发动代价（Cost）处理函数
function c7721912.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中的装备魔法卡且可以加入手牌
function c7721912.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果②的发动准备与效果分类设置函数
function c7721912.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己卡组中是否存在至少1张装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c7721912.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理函数，从卡组选择1张装备魔法卡加入手牌并给对方确认
function c7721912.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c7721912.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
