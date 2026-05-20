--Live☆Twin リィラ・スウィート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方连锁自己的「直播☆双子」卡的效果的发动把魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个对方的效果无效。
-- ②：这张卡在墓地存在，自己场上有「姬丝基勒」怪兽存在的场合才能发动。这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果①（手牌丢弃无效对方连锁）和效果②（墓地自身特殊召唤及额外卡组召唤限制）
function s.initial_effect(c)
	-- ①：对方连锁自己的「直播☆双子」卡的效果的发动把魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个对方的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「姬丝基勒」怪兽存在的场合才能发动。这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：检查当前连锁是否可被无效，且上一个连锁是我方发动的「直播☆双子」卡的效果，且当前连锁是对方发动的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的效果是否可以被无效
	if not Duel.IsChainDisablable(ev) then return false end
	-- 获取上一个连锁（即被对方连锁的我方效果）的效果和发动玩家
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandler():IsSetCard(0x1151) and p==tp and rp==1-tp
end
-- 效果①的发动代价：检查并执行将手牌中的这张卡丢弃
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动准备：设置效果分类为无效，并指定要无效的连锁卡片
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含“使效果无效”的操作，目标为对方发动的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的效果处理：使对方发动的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁（对方发动的效果）的效果无效
	Duel.NegateEffect(ev)
end
-- 过滤条件：自己场上表侧表示的「姬丝基勒」怪兽
function s.spfilter(c)
	return c:IsSetCard(0x152) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上存在表侧表示的「姬丝基勒」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件（表侧表示的「姬丝基勒」怪兽）的卡
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动准备：检查怪兽区域是否有空位，以及自身是否可以特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示该效果包含“特殊召唤”的操作，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将自身特殊召唤，并注册“只要在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能从额外卡组特殊召唤”的限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关、是否受王家长眠之谷影响，并尝试将其以表侧表示特殊召唤，若成功则执行后续限制
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是恶魔族怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制条件：不能从额外卡组特殊召唤非恶魔族的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_FIEND)
end
