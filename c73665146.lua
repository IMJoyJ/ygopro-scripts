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
c73665146.mentioned_counter={
	[0x1]=true,
}
-- ①效果处理：判断为对方玩家抽卡时给自身放置1个魔力指示物
function c73665146.addc(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 计算攻击力上升数值：自身魔力指示物数量×500
function c73665146.attackup(e,c)
	return c:GetCounter(0x1)*500
end
-- ③效果发动条件检查：自身魔力指示物数量为5且为自己回合的准备阶段
function c73665146.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身魔力指示物数量是否达到5且当前为自己的回合
	return e:GetHandler():GetCounter(0x1)==5 and tp==Duel.GetTurnPlayer()
end
-- ③效果发动Cost：把满足条件的此卡送去墓地
function c73665146.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为Cost送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤条件：「沉默魔术师 LV8」且可以忽视条件特殊召唤
function c73665146.spfilter(c,e,tp)
	return c:IsCode(72443568) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- ③效果发动准备：设置从手牌·卡组特殊召唤「沉默魔术师 LV8」的操作信息
function c73665146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放此卡后怪兽区域是否有可用于特召的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌或卡组是否存在可特殊召唤的「沉默魔术师 LV8」
		and Duel.IsExistingMatchingCard(c73665146.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌·卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ③效果处理：从手牌或卡组选择1只「沉默魔术师 LV8」忽视召唤条件特殊召唤
function c73665146.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件检查：主要怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组选择1只满足条件的「沉默魔术师 LV8」
	local g=Duel.SelectMatchingCard(tp,c73665146.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽表侧表示特殊召唤并忽略召唤条件
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
