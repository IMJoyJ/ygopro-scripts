--サイレント・マジシャン LV4
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次对方抽卡，给这张卡放置1个魔力指示物（最多5个）。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500。
-- ③：这张卡有第5个魔力指示物被放置的下次的自己回合的准备阶段，把有5个魔力指示物放置的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默魔术师 LV8」特殊召唤。
function c73665146.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,5)
	-- 只要这张卡在怪兽区域存在，每次对方抽卡，给这张卡放置1个魔力指示物（最多5个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c73665146.addc)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升这张卡的魔力指示物数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c73665146.attackup)
	c:RegisterEffect(e2)
	-- 这张卡有第5个魔力指示物被放置的下次的自己回合的准备阶段，把有5个魔力指示物放置的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默魔术师 LV8」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73665146,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c73665146.spcon)
	e3:SetCost(c73665146.spcost)
	e3:SetTarget(c73665146.sptg)
	e3:SetOperation(c73665146.spop)
	c:RegisterEffect(e3)
end
c73665146.lvup={72443568}
c73665146.mentioned_counter={
	[0x1]=true,
}
-- 效果处理：当发生抽卡时，如果抽卡玩家是对方，则给这张卡放置1个魔力指示物。
function c73665146.addc(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 计算并返回增加的攻击力数值：这张卡上的魔力指示物数量乘以500。
function c73665146.attackup(e,c)
	return c:GetCounter(0x1)*500
end
-- 发动条件：判断这张卡上是否有5个魔力指示物，并且当前是否为自己回合的准备阶段。
function c73665146.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡上是否有5个魔力指示物，并且当前回合的玩家是己方。
	return e:GetHandler():GetCounter(0x1)==5 and tp==Duel.GetTurnPlayer()
end
-- 发动代价：检查这张卡能否送去墓地作为代价，并将其作为代价送去墓地。
function c73665146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把作为代价的这张卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「沉默魔术师 LV8」且能够被特殊召唤的卡。
function c73665146.spfilter(c,e,tp)
	return c:IsCode(72443568) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果对象设定：检查场上有无空余位置，以及手卡·卡组中是否有满足条件的「沉默魔术师 LV8」。
function c73665146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否还有空位（由于此卡送墓做代价，判断大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组中是否存在1只满足过滤条件的卡。
		and Duel.IsExistingMatchingCard(c73665146.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置将卡组或手卡的卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：从手卡·卡组选择1只「沉默魔术师 LV8」特殊召唤。
function c73665146.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区域是否还有大于0的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给己方发送提示信息：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1只满足条件的「沉默魔术师 LV8」。
	local g=Duel.SelectMatchingCard(tp,c73665146.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选出的那只怪兽表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
