--ドラゴンメイド・ルフト
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
function c15848542.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以场上1只表侧表示怪兽为对象才能发动。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15848542,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,15848542)
	e1:SetCost(c15848542.actcost)
	e1:SetTarget(c15848542.acttg)
	e1:SetOperation(c15848542.actop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c15848542.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15848542,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,15848543)
	e3:SetTarget(c15848542.sptg)
	e3:SetOperation(c15848542.spop)
	c:RegisterEffect(e3)
end
-- 将此卡从手卡丢弃作为cost
function c15848542.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且具有效果
function c15848542.actfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT)
end
-- 选择一个满足条件的场上表侧表示怪兽作为效果对象
function c15848542.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15848542.actfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c15848542.actfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一个表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足条件的场上表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c15848542.actfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 使目标怪兽在本回合不能发动场上发动的效果
function c15848542.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个使目标怪兽不能发动效果的永续效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且为融合怪兽
function c15848542.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 判断自己场上是否存在表侧表示的融合怪兽
function c15848542.indcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的融合怪兽
	return Duel.IsExistingMatchingCard(c15848542.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断手卡中是否为3星「半龙女仆」怪兽
function c15848542.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动效果的条件
function c15848542.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡中是否存在满足条件的「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c15848542.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果操作信息为将此卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置效果操作信息为特殊召唤1只「半龙女仆」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果的发动，将此卡送回手卡并特殊召唤1只「半龙女仆」怪兽
function c15848542.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在场上且成功送回手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 检查此卡是否在手卡且自己场上存在可用怪兽区域
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的「半龙女仆」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只满足条件的「半龙女仆」怪兽
		local g=Duel.SelectMatchingCard(tp,c15848542.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
