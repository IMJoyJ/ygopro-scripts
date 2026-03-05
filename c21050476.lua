--ARG☆S－熱闘のパルテ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把手卡的这张卡给对方观看才能发动。自己场上1张表侧表示的「阿尔戈☆群星」永续陷阱卡回到手卡，这张卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己场上的其他的「阿尔戈☆群星」怪兽种类×700。
-- ③：把场上的这张卡除外才能发动。从手卡把1张永续陷阱卡盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 注册三个效果：①特殊召唤效果、②攻击力上升效果、③盖放效果
function s.initial_effect(c)
	-- ①：自己·对方回合，把手卡的这张卡给对方观看才能发动。自己场上1张表侧表示的「阿尔戈☆群星」永续陷阱卡回到手卡，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升自己场上的其他的「阿尔戈☆群星」怪兽种类×700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：把场上的这张卡除外才能发动。从手卡把1张永续陷阱卡盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	-- 将此卡除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 效果发动时检查是否公开手卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤满足条件的「阿尔戈☆群星」永续陷阱卡
function s.spfilter(c,tp,chk)
	return c:IsSetCard(0x1c1) and c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsFaceup() and c:IsAbleToHand()
		-- 若场上存在空怪兽区则允许选择，否则强制选择
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- 设置特殊召唤效果的目标为自身和场上满足条件的永续陷阱卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将一张卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
	-- 设置连锁操作信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local rg=nil
	-- 检查场上是否存在满足条件的永续陷阱卡
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) then
		-- 选择场上满足条件的1张永续陷阱卡
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,true)
	else
		-- 若无空怪兽区则强制选择1张永续陷阱卡
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		-- 显示所选卡的动画效果
		Duel.HintSelection(rg)
		-- 将所选卡送入手牌并确认是否成功
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)~=0 and rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将此卡特殊召唤到场上
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 计算并设置此卡的攻击力
function s.atkval(e,c)
	-- 获取场上所有满足条件的「阿尔戈☆群星」怪兽
	local g=Duel.GetMatchingGroup(s.bfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetClassCount(Card.GetCode)*700
end
-- 过滤场上满足条件的「阿尔戈☆群星」怪兽
function s.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c1)
end
-- 过滤满足条件的永续陷阱卡
function s.setfilter(c)
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsSSetable()
end
-- 设置盖放效果的目标为手牌中满足条件的永续陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 执行盖放效果的处理流程
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择手牌中满足条件的1张永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将所选卡盖放到场上
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 使盖放的卡在盖放的回合也能发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"适用「阿尔戈☆群星-热斗之帕耳忒」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
