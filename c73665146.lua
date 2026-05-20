--サイレント・マジシャン LV4
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次对方抽卡，给这张卡放置1个魔力指示物（最多5个）。
-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500。
-- ③：这张卡有第5个魔力指示物被放置的下次的自己回合的准备阶段，把有5个魔力指示物放置的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默魔术师 LV8」特殊召唤。
function c73665146.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,5)
	-- ①：只要这张卡在怪兽区域存在，每次对方抽卡，给这张卡放置1个魔力指示物（最多5个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c73665146.addc)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的魔力指示物数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c73665146.attackup)
	c:RegisterEffect(e2)
	-- ③：这张卡有第5个魔力指示物被放置的下次的自己回合的准备阶段，把有5个魔力指示物放置的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默魔术师 LV8」特殊召唤。
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
-- 对方抽卡时，给这张卡放置1个魔力指示物的效果处理
function c73665146.addc(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 计算攻击力上升值，为魔力指示物数量×500
function c73665146.attackup(e,c)
	return c:GetCounter(0x1)*500
end
-- 检查特殊召唤效果的发动条件：这张卡有5个魔力指示物，且当前为自己的回合
function c73665146.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足有5个魔力指示物且为当前回合玩家的回合
	return e:GetHandler():GetCounter(0x1)==5 and tp==Duel.GetTurnPlayer()
end
-- 特殊召唤效果的发动代价：检查并把自身送去墓地
function c73665146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：检查卡片是否为「沉默魔术师 LV8」且可以被特殊召唤
function c73665146.spfilter(c,e,tp)
	return c:IsCode(72443568) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 特殊召唤效果的发动目标：检查怪兽区域是否有空位，以及手卡或卡组是否存在可特殊召唤的「沉默魔术师 LV8」
function c73665146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（检查是否可行）时，判断怪兽区域是否有可用位置（因为自身作为代价送去墓地，所以可用位置数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查手卡或卡组是否存在至少1张满足特殊召唤条件的「沉默魔术师 LV8」
		and Duel.IsExistingMatchingCard(c73665146.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的效果处理：从手卡或卡组选择1只「沉默魔术师 LV8」特殊召唤
function c73665146.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1张满足条件的「沉默魔术师 LV8」
	local g=Duel.SelectMatchingCard(tp,c73665146.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
