--ARG☆S－熱闘のパルテ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把手卡的这张卡给对方观看才能发动。自己场上1张表侧表示的「阿尔戈☆群星」永续陷阱卡回到手卡，这张卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己场上的其他的「阿尔戈☆群星」怪兽种类×700。
-- ③：把场上的这张卡除外才能发动。从手卡把1张永续陷阱卡盖放。这个效果盖放的卡在盖放的回合也能发动。
local s,id,o=GetID()
-- 初始化函数：注册这张卡的4个效果——①手卡发动的诱发即时特殊召唤效果（自由时点，1回合1次）、②只影响自身的攻击力上升永续效果、③克隆的守备力上升永续效果、④把自身除外从手卡盖放永续陷阱的起动效果（1回合1次）
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己·对方回合，把手卡的这张卡给对方观看才能发动。自己场上1张表侧表示的「阿尔戈☆群星」永续陷阱卡回到手卡，这张卡特殊召唤。
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
	-- 这个卡名的①③的效果1回合各能使用1次。③：把场上的这张卡除外才能发动。从手卡把1张永续陷阱卡盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	-- 设置发动代价：把场上的这张卡除外（aux.bfgcost即除外自身作为代价的标准写法）
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- ①效果的发动代价检查：确认手卡的这张卡处于非公开状态（发动时需把手卡的这张卡给对方观看）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：选择自己场上表侧表示、可以回到手卡的「阿尔戈☆群星」（系列0x1c1）永续陷阱卡，且该卡离场后自己场上还有可用的主要怪兽区（处理阶段不检查格子）
function s.spfilter(c,tp,chk)
	return c:IsSetCard(0x1c1) and c:IsAllTypes(TYPE_CONTINUOUS|TYPE_TRAP) and c:IsFaceup() and c:IsAbleToHand()
		-- 附加条件：这张永续陷阱卡回到手卡后自己主要怪兽区仍有空位（chk为假即效果处理阶段时不再检查）
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- ①效果的发动条件检查：自己场上存在可回到手卡的「阿尔戈☆群星」表侧表示永续陷阱卡，且手卡的这张卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1张满足条件的可回到手卡且离场后有空位的「阿尔戈☆群星」永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：此效果包含让场上1张卡回到手卡的处理（具体卡在处理时确定，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
	-- 设置操作信息：此效果将把确定的1张卡（这张卡自身）从手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
-- ①效果的处理：提示并让自己选择场上1张满足条件的「阿尔戈☆群星」永续陷阱卡回到手卡，成功回手且这张卡仍与连锁关联、可以特殊召唤的场合，把手卡的这张卡表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local rg=nil
	-- 检查此时是否仍存在满足条件且离场后能空出怪兽区的永续陷阱卡，以决定选择范围
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,true) then
		-- 让玩家从自己场上选择1张满足条件的永续陷阱卡（要求该卡离场后仍有可用怪兽区）
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,true)
	else
		-- 若没有能空出怪兽区的卡，则让玩家从自己场上选择1张满足条件的永续陷阱卡（不再检查怪兽区）
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		-- 为选中的卡显示被选为对象的动画并记录这些卡被选择
		Duel.HintSelection(rg)
		-- 把选择的卡以效果原因送回持有者的手卡，并确认该卡确实回到了手卡
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)~=0 and rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0
			and c:IsRelateToChain() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 把手卡的这张卡以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的数值计算：返回自己场上其他的表侧表示「阿尔戈☆群星」怪兽的卡名种类数×700，作为攻击力·守备力上升的数值
function s.atkval(e,c)
	-- 获取自己怪兽区中除这张卡以外表侧表示的「阿尔戈☆群星」怪兽的集合
	local g=Duel.GetMatchingGroup(s.bfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetClassCount(Card.GetCode)*700
end
-- 过滤函数：表侧表示的「阿尔戈☆群星」（系列0x1c1）怪兽卡
function s.bfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c1)
end
-- 过滤函数：可以盖放到魔法·陷阱区域的永续陷阱卡
function s.setfilter(c)
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsSSetable()
end
-- ③效果的发动条件检查：自己手卡存在可以盖放的永续陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张可以盖放的永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- ③效果的处理：提示并让自己从手卡选择1张永续陷阱卡盖放到魔法·陷阱区域，盖放成功的场合，赋予那张卡「在盖放的回合也能发动」的效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己手卡选择1张可以盖放的永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡盖放到自己的魔法·陷阱区域，并确认盖放成功
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
