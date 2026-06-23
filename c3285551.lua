--アラメシアの儀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把特殊召唤的怪兽以外的场上的怪兽的效果发动。
-- ①：自己场上没有「勇者衍生物」存在的场合才能发动。在自己场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。自己场上没有「命运之旅路」存在的场合，可以再从卡组选1张「命运之旅路」在自己的魔法与陷阱区域表侧表示放置。
function c3285551.initial_effect(c)
	-- 记录此卡与「勇者衍生物」的关联
	aux.AddCodeList(c,3285552)
	-- ①：自己场上没有「勇者衍生物」存在的场合才能发动。在自己场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。自己场上没有「命运之旅路」存在的场合，可以再从卡组选1张「命运之旅路」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,3285551+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c3285551.condition)
	e1:SetCost(c3285551.cost)
	e1:SetTarget(c3285551.target)
	e1:SetOperation(c3285551.operation)
	c:RegisterEffect(e1)
	-- 设置发动次数计数器，限制每回合只能发动一次
	Duel.AddCustomActivityCounter(3285551,ACTIVITY_CHAIN,c3285551.chainfilter)
end
-- 过滤连锁中是否为怪兽召唤且非特殊召唤的怪兽效果
function c3285551.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	-- 获取当前连锁的触发位置
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and not rc:IsSummonType(SUMMON_TYPE_SPECIAL))
end
-- 检查场上是否存在「勇者衍生物」
function c3285551.cfilter0(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 判断发动条件：自己场上没有「勇者衍生物」
function c3285551.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动条件：自己场上没有「勇者衍生物」
	return not Duel.IsExistingMatchingCard(c3285551.cfilter0,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置发动费用：本回合未发动过效果
function c3285551.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置发动费用：本回合未发动过效果
	if chk==0 then return Duel.GetCustomActivityCount(3285551,tp,ACTIVITY_CHAIN)==0 end
	-- 设置发动费用：本回合未发动过效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(c3285551.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能发动效果的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果：非特殊召唤的怪兽效果不能发动
function c3285551.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE)
end
-- 设置效果处理目标：准备特殊召唤衍生物
function c3285551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以特殊召唤衍生物
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查是否可以特殊召唤衍生物
		Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH) end
	-- 设置操作信息：准备特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：准备特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 检查场上是否存在「命运之旅路」
function c3285551.cfilter(c)
	return c:IsCode(39568067) and c:IsFaceup()
end
-- 检查卡组中是否存在「命运之旅路」且未被禁止
function c3285551.setfilter(c)
	return c:IsCode(39568067) and not c:IsForbidden()
end
-- 设置效果处理：特殊召唤衍生物
function c3285551.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH) then return end
	-- 创建「勇者衍生物」
	local token=Duel.CreateToken(tp,3285552)
	-- 将「勇者衍生物」特殊召唤
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 检索卡组中「命运之旅路」
	local g=Duel.GetMatchingGroup(c3285551.setfilter,tp,LOCATION_DECK,0,nil)
	-- 检查场上是否已存在「命运之旅路」
	if not Duel.IsExistingMatchingCard(c3285551.cfilter,tp,LOCATION_SZONE,0,1,nil)
		-- 检查魔法与陷阱区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetCount()>0
		-- 询问是否发动放置「命运之旅路」的效果
		and Duel.SelectYesNo(tp,aux.Stringid(3285551,0)) then  --"是否从卡组把「命运之旅路」放置？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要放置的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡放置到魔法与陷阱区域
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
