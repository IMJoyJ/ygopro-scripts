--召喚師アレイスター
-- 效果：
-- ①：自己·对方回合，把这张卡从手卡送去墓地，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升1000。
-- ②：这张卡召唤·反转的场合才能发动。从卡组把1张「召唤魔术」加入手卡。
function c86120751.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡送去墓地，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86120751,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	-- 设置效果在伤害步骤中仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c86120751.adcost)
	e1:SetTarget(c86120751.adtg)
	e1:SetOperation(c86120751.adop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转的场合才能发动。从卡组把1张「召唤魔术」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86120751,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c86120751.thtg)
	e2:SetOperation(c86120751.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 效果①的Cost（发动代价）判定与执行：把手卡的这张卡送去墓地
function c86120751.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将自身（手卡的这张卡）送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上表侧表示的融合怪兽
function c86120751.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 效果①的对象选择与发动准备
function c86120751.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86120751.filter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的融合怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c86120751.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的融合怪兽作为效果对象
	Duel.SelectTarget(tp,c86120751.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理：使作为对象的怪兽攻击力·守备力直到回合结束时上升1000
function c86120751.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤条件：卡组中卡名为「召唤魔术」且能加入手卡的卡
function c86120751.thfilter(c)
	return c:IsCode(74063034) and c:IsAbleToHand()
end
-- 效果②的发动准备与效果分类声明
function c86120751.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「召唤魔术」
	if chk==0 then return Duel.IsExistingMatchingCard(c86120751.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，声明该效果包含“从卡组将1张卡加入手卡”的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1张「召唤魔术」加入手卡并给对方确认
function c86120751.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足条件的「召唤魔术」
	local tc=Duel.GetFirstMatchingCard(c86120751.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
