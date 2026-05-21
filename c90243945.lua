--ワイトプリンセス
-- 效果：
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「白骨王子」送去墓地。
-- ③：把自己的手卡·场上的这张卡送去墓地才能发动。场上的全部怪兽的攻击力·守备力直到回合结束时下降那等级或者阶级×300。这个效果在对方回合也能发动。
function c90243945.initial_effect(c)
	-- 注册一个永续效果，使这张卡在墓地存在时卡名当作「白骨」使用
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「白骨王子」送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90243945,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c90243945.tgtg)
	e2:SetOperation(c90243945.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：把自己的手卡·场上的这张卡送去墓地才能发动。场上的全部怪兽的攻击力·守备力直到回合结束时下降那等级或者阶级×300。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90243945,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e4:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动
	e4:SetCondition(aux.dscon)
	e4:SetCost(c90243945.atkcost)
	e4:SetTarget(c90243945.atktg)
	e4:SetOperation(c90243945.atkop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中卡名为「白骨王子」且能送去墓地的卡
function c90243945.tgfilter(c)
	return c:IsCode(57473560) and c:IsAbleToGrave()
end
-- 效果②的发动检测与效果分类注册
function c90243945.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以送去墓地的「白骨王子」
	if chk==0 then return Duel.IsExistingMatchingCard(c90243945.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只「白骨王子」送去墓地
function c90243945.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第1只可以送去墓地的「白骨王子」
	local tg=Duel.GetFirstMatchingCard(c90243945.tgfilter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将目标卡片因效果送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
-- 效果③的发动代价处理：将自身送去墓地
function c90243945.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤场上表侧表示存在且有等级或阶级的怪兽
function c90243945.atkfilter(c)
	return c:IsFaceup() and (c:IsLevelAbove(1) or c:IsRankAbove(1))
end
-- 效果③的发动检测
function c90243945.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除自身以外的表侧表示且有等级或阶级的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90243945.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
-- 效果③的效果处理：使场上全部怪兽的攻击力·守备力下降其等级或阶级×300
function c90243945.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示且有等级或阶级的怪兽
	local g=Duel.GetMatchingGroup(c90243945.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local val=0
		if tc:IsType(TYPE_XYZ) then val=tc:GetRank()*-300
		else val=tc:GetLevel()*-300 end
		-- 攻击力·守备力直到回合结束时下降那等级或者阶级×300
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
