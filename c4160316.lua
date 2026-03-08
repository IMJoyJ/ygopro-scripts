--騎士の絆
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡在墓地存在的状态，自己场上有「百夫长骑士」同调怪兽特殊召唤的场合，把这张卡除外，以自己墓地1只「百夫长骑士」怪兽为对象才能发动。那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片的两个效果：①永续发动效果（从手牌或墓地将一只百夫长骑士怪兽当作永续陷阱卡使用）和②墓地触发效果（当自己场上有百夫长骑士同调怪兽特殊召唤时，将此卡除外并选择墓地一只百夫长骑士怪兽当作永续陷阱卡使用）
function s.initial_effect(c)
	-- 注册一个监听此卡进入墓地事件的单次持续效果，用于标记此卡是否已进入墓地，以供后续效果判断使用
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：从自己的手卡·墓地把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有「百夫长骑士」同调怪兽特殊召唤的场合，把这张卡除外，以自己墓地1只「百夫长骑士」怪兽为对象才能发动。那只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.ptcon)
	-- 将此卡从游戏中除外作为发动②效果的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.pttg)
	e2:SetOperation(s.ptop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选出属于百夫长骑士卡组、是怪兽卡且未被禁止的卡片
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果①的发动条件判断函数：检查玩家场上是否有足够的魔法与陷阱区域空位，并且手牌或墓地是否存在满足条件的百夫长骑士怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and 1 or 0
	-- 检查玩家场上是否有足够的魔法与陷阱区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		-- 检查玩家手牌或墓地是否存在至少一张满足条件的百夫长骑士怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
end
-- 效果①的处理函数：选择一张满足条件的百夫长骑士怪兽从手牌或墓地移至魔法与陷阱区域并转换为永续陷阱卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的魔法与陷阱区域空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从玩家手牌或墓地选择一张满足条件的百夫长骑士怪兽
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
	-- 将选中的怪兽移至魔法与陷阱区域
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将选中的怪兽转换为永续陷阱卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选出属于百夫长骑士卡组、是同调怪兽且为玩家控制的卡片
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsSetCard(0x1a2) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件判断函数：检查是否有满足条件的百夫长骑士同调怪兽被特殊召唤成功
function s.ptcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetLabelObject():GetLabelObject())
end
-- 效果②的发动条件判断函数：检查玩家墓地是否存在满足条件的百夫长骑士怪兽
function s.pttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查玩家场上是否有足够的魔法与陷阱区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家墓地是否存在至少一张满足条件的百夫长骑士怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从玩家墓地选择一张满足条件的百夫长骑士怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将有1张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的处理函数：将选中的墓地百夫长骑士怪兽移至魔法与陷阱区域并转换为永续陷阱卡
function s.ptop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 将选中的怪兽移至魔法与陷阱区域
	if tc:IsRelateToEffect(e) and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将选中的怪兽转换为永续陷阱卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
