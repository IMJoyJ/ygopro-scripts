--U.A.コリバルリバウンダー
-- 效果：
-- 「超级运动员 角逐篮板手」的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让「超级运动员 角逐篮板手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：这张卡召唤或者对方回合中的特殊召唤成功的场合才能发动。从自己的手卡·墓地选「超级运动员 角逐篮板手」以外的1只「超级运动员」怪兽特殊召唤。
function c17264592.initial_effect(c)
	-- ①：这张卡可以让「超级运动员 角逐篮板手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,17264592+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c17264592.sprcon)
	e1:SetTarget(c17264592.sprtg)
	e1:SetOperation(c17264592.sprop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤或者对方回合中的特殊召唤成功的场合才能发动。从自己的手卡·墓地选「超级运动员 角逐篮板手」以外的1只「超级运动员」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,17264593)
	e2:SetTarget(c17264592.sptg)
	e2:SetOperation(c17264592.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c17264592.spcon)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否有满足条件的「超级运动员」怪兽可以返回手卡
function c17264592.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(17264592) and c:IsAbleToHandAsCost()
		-- 判断目标怪兽所在玩家场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足：场上是否存在满足条件的「超级运动员」怪兽
function c17264592.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的「超级运动员」怪兽
	return Duel.IsExistingMatchingCard(c17264592.thfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 设置特殊召唤的目标：选择一个满足条件的怪兽返回手卡
function c17264592.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的「超级运动员」怪兽
	local g=Duel.GetMatchingGroup(c17264592.thfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行将目标怪兽送回手牌的操作
function c17264592.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽送回手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 过滤函数，用于判断手卡或墓地是否有满足条件的「超级运动员」怪兽可以特殊召唤
function c17264592.spfilter(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(17264592)
end
-- 设置发动条件：判断是否满足特殊召唤的条件
function c17264592.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在满足条件的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c17264592.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：确定特殊召唤的卡的来源和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作：从手卡或墓地选择并特殊召唤满足条件的怪兽
function c17264592.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地中选择满足条件的「超级运动员」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17264592.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断发动条件：是否在对方回合中特殊召唤成功
function c17264592.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己
	return Duel.GetTurnPlayer()~=tp
end
