--ARG☆S－熱闘のパルテ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把手卡的这张卡给对方观看才能发动。自己场上1张表侧表示的「阿尔戈☆群星」永续陷阱卡回到手卡，这张卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己场上的其他的「阿尔戈☆群星」怪兽种类×700。
-- ③：把场上的这张卡除外才能发动。从手卡把1张永续陷阱卡盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 初始化卡片效果：注册①从手卡把自身特殊召唤的诱发即时效果、②攻击力·守备力上升的永续效果（攻守各一个效果）、③除外自身从手卡盖放永续陷阱的起动效果
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
	-- 设置代价：把场上的这张卡除外才能发动
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 代价检测：确认手卡的这张卡未处于公开状态（即尚未给对方观看），满足展示手卡发动的前提
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：筛选自己场上表侧表示的「阿尔戈☆群星」永续陷阱卡且可以回到手卡的卡，并保证其离开后有空余怪兽区
function s.spfilter(c,tp,chk)
	return c:IsSetCard(0x1c1) and c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsFaceup() and c:IsAbleToHand()
		-- 确认该卡回到手卡后自己场上仍有可用的主要怪兽区（发动前检测时才需要，处理时不校验）
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- 目标检测：确认自己场上存在可回到手卡的「阿尔戈☆群星」永续陷阱卡，且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检测：自己场上存在至少1张满足条件的表侧表示「阿尔戈☆群星」永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将让1张场上的卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
	-- 设置操作信息：本次连锁将把这张卡从手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
-- 效果处理：让玩家选择1张自己场上表侧表示的「阿尔戈☆群星」永续陷阱卡回到手卡，成功后把这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家提示请选择要回到手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local rg=nil
	-- 若场上仍存在离开后能保证空余怪兽区的目标卡
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) then
		-- 让玩家选择1张满足条件（含怪兽区空格校验）的永续陷阱卡
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,true)
	else
		-- 若没有满足怪兽区条件的卡，则放宽校验让玩家选择1张满足条件的永续陷阱卡
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画提示
		Duel.HintSelection(rg)
		-- 确认选择的卡成功回到手卡，且这张卡仍与当前连锁关联并可以被特殊召唤
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)~=0 and rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0
			and c:IsRelateToChain() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 把这张卡从手卡表侧攻击表示特殊召唤到自己场上
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 计算攻守上升值：统计自己场上其他的表侧表示「阿尔戈☆群星」怪兽的种类数，乘以700作为上升数值
function s.atkval(e,c)
	-- 获取自己场上除这张卡以外表侧表示的「阿尔戈☆群星」怪兽组
	local g=Duel.GetMatchingGroup(s.bfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetClassCount(Card.GetCode)*700
end
-- 过滤函数：筛选表侧表示的「阿尔戈☆群星」怪兽
function s.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c1)
end
-- 过滤函数：筛选手卡中可以盖放的永续陷阱卡
function s.setfilter(c)
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsSSetable()
end
-- 目标检测：确认手卡存在可以盖放的永续陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：手卡存在至少1张可以盖放的永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 效果处理：从手卡选择1张永续陷阱卡盖放，并赋予该卡「在盖放的回合也能发动」的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从手卡选择1张可以盖放的永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 确认选卡存在并成功盖放到场上
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"适用「阿尔戈☆群星-热斗之帕耳忒」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
