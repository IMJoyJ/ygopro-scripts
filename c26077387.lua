--閃刀姫－レイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡解放才能发动。从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的「闪刀姬」连接怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡特殊召唤。
function c26077387.initial_effect(c)
	-- ①：自己·对方回合，把这张卡解放才能发动。从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26077387,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26077387)
	e1:SetCost(c26077387.spcost1)
	e1:SetTarget(c26077387.sptg1)
	e1:SetOperation(c26077387.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的「闪刀姬」连接怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26077387,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,26077388)
	e2:SetCondition(c26077387.spcon2)
	e2:SetTarget(c26077387.sptg2)
	e2:SetOperation(c26077387.spop2)
	c:RegisterEffect(e2)
end
-- 效果发动时的解放费用处理
function c26077387.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 用于筛选额外卡组中可特殊召唤的「闪刀姬」怪兽的过滤函数
function c26077387.spfilter1(c,e,tp,ec)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外怪兽区域是否有足够的空位
		and Duel.GetLocationCountFromEx(tp,tp,ec,c,0x60)>0
end
-- 效果的发动条件判断
function c26077387.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在满足条件的额外卡组怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26077387.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果的处理流程
function c26077387.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c26077387.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
end
-- 用于判断离场怪兽是否满足特殊召唤条件的过滤函数
function c26077387.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and c:IsPreviousSetCard(0x1115) and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- 效果发动的条件判断
function c26077387.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26077387.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 效果的发动条件判断
function c26077387.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，提示将要特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果的处理流程
function c26077387.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身从墓地特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
