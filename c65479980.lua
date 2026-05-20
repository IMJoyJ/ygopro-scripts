--S－Force ドッグ・タッグ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「治安战警队」怪兽存在，对方对怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己主要阶段中，自己的「治安战警队」怪兽的正对面的对方怪兽不能把效果发动。
function c65479980.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「治安战警队」怪兽存在，对方对怪兽的召唤·特殊召唤成功的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65479980,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,65479980)
	e1:SetCondition(c65479980.spcon)
	e1:SetTarget(c65479980.sptg)
	e1:SetOperation(c65479980.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己主要阶段中，自己的「治安战警队」怪兽的正对面的对方怪兽不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c65479980.actcon)
	e3:SetTarget(c65479980.actlimit)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「治安战警队」怪兽
function c65479980.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156)
end
-- 过滤条件：由对方召唤·特殊召唤的怪兽
function c65479980.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果①的发动条件：对方对怪兽召唤·特殊召唤成功，且自己场上有表侧表示的「治安战警队」怪兽存在
function c65479980.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65479980.cfilter,1,nil,tp)
		-- 检查自己场上是否存在表侧表示的「治安战警队」怪兽
		and Duel.IsExistingMatchingCard(c65479980.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备：检查怪兽区域空位数以及自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c65479980.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：若此卡仍在手卡，则将此卡表侧表示特殊召唤
function c65479980.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的适用条件：自己的主要阶段
function c65479980.actcon(e)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为自己的主要阶段1或主要阶段2
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 过滤条件：自己场上表侧表示的「治安战警队」怪兽
function c65479980.actfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 效果②的限制对象：检查该对方怪兽的同纵列（正对面）是否存在自己的「治安战警队」怪兽
function c65479980.actlimit(e,c)
	local face=c:GetColumnGroup()
	return face:IsExists(c65479980.actfilter,1,nil,e:GetHandlerPlayer())
end
