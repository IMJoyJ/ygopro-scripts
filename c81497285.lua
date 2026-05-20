--迷宮城の白銀姫
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：「迷宫城的白银姬」以外的「拉比林斯迷宫」卡的效果或者通常陷阱卡发动的自己·对方回合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：只要自己场上有里侧表示卡存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ③：通常陷阱卡发动时才能发动。和那张卡卡名不同的1张通常陷阱卡从卡组到自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：「迷宫城的白银姬」以外的「拉比林斯迷宫」卡的效果或者通常陷阱卡发动的自己·对方回合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有里侧表示卡存在，对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.dcon)
	-- 设置不会成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方卡片的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：通常陷阱卡发动时才能发动。和那张卡卡名不同的1张通常陷阱卡从卡组到自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
	-- 注册一个自定义活动计数器，用于检测连锁中是否有特定卡片效果或通常陷阱卡的发动
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器的过滤函数，排除「迷宫城的白银姬」自身，仅对「拉比林斯迷宫」卡的效果或通常陷阱卡的发动进行计数
function s.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	return rc:IsCode(id) or not ((rc:GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE))
		or (rc:IsSetCard(0x17e)))
end
-- 特殊召唤效果的发动条件：本回合自己或对方曾发动过「拉比林斯迷宫」卡的效果或通常陷阱卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己本回合是否发动过满足条件的卡或效果
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
		-- 或者检查对方本回合是否发动过满足条件的卡或效果
		or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- 特殊召唤效果的靶向与可行性检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动效果时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 抗性效果的发动条件函数
function s.dcon(e)
	-- 检查自己场上是否存在里侧表示的卡
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 盖放效果的发动条件：通常陷阱卡发动时
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:GetType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤卡组中与发动的通常陷阱卡卡名不同、且可以盖放的通常陷阱卡
function s.setfilter(c,rc)
	return not c:IsCode(rc:GetCode()) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 盖放效果的靶向与可行性检查函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 在发动效果时，检查卡组中是否存在满足条件的通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,rc) end
end
-- 盖放效果的执行函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足过滤条件的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if g:GetCount()>0 then
		-- 将选择的通常陷阱卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
