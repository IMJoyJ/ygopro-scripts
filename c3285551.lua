--アラメシアの儀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把特殊召唤的怪兽以外的场上的怪兽的效果发动。
-- ①：自己场上没有「勇者衍生物」存在的场合才能发动。在自己场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。自己场上没有「命运之旅路」存在的场合，可以再从卡组选1张「命运之旅路」在自己的魔法与陷阱区域表侧表示放置。
function c3285551.initial_effect(c)
	-- 记录本卡（阿拉弥赛亚之仪）的卡名记述了「勇者衍生物」（3285552），使系统中与记载卡名相关的检索/判定能够识别本卡。
	aux.AddCodeList(c,3285552)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把特殊召唤的怪兽以外的场上的怪兽的效果发动。①：自己场上没有「勇者衍生物」存在的场合才能发动。在自己场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。自己场上没有「命运之旅路」存在的场合，可以再从卡组把1张「命运之旅路」在自己的魔法与陷阱区域表侧表示放置。
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
	-- 注册本回合自定义活动计数器（id为3285551，活动类型为连锁发动ACTIVITY_CHAIN），凡是c3285551.chainfilter判定为false的连锁发动都会被计数；代价阶段会检查该计数是否为0，以此禁止本回合已经发动过非特殊召唤怪兽的场上怪兽效果。
	Duel.AddCustomActivityCounter(3285551,ACTIVITY_CHAIN,c3285551.chainfilter)
end
-- 连锁过滤器：判断本次发动是否属于“场上怪兽效果的发动”且发动怪兽位于主要怪兽区、不是以特殊召唤方式出场的怪兽；若属于则返回false，使自定义计数器记录这次发动，从而配合cost实现“这张卡发动的回合，自己不能把特殊召唤的怪兽以外的场上的怪兽的效果发动”的自肃。
function c3285551.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	-- 取得当前连锁发动时所在的位置（如主要怪兽区LOCATION_MZONE），用于判断是否是场上怪兽效果的发动。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and not rc:IsSummonType(SUMMON_TYPE_SPECIAL))
end
-- 过滤函数：用于检查场上是否存在表侧表示的「勇者衍生物」；卡号必须为3285552且表侧表示。
function c3285551.cfilter0(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 发动条件函数：只有自己场上没有表侧表示的「勇者衍生物」时，才能发动阿拉弥赛亚之仪。
function c3285551.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上（怪兽区和魔陷区）是否存在至少1张表侧「勇者衍生物」；不存在返回true，即满足发动条件。
	return not Duel.IsExistingMatchingCard(c3285551.cfilter0,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 代价处理：先确认本回合自定义连锁计数为0（没有发动过非特殊召唤怪兽的场上怪兽效果）；随后给己方注册一个回合结束前有效的禁发效果（EFFECT_CANNOT_ACTIVATE），禁止本回合自己再发动非特殊召唤怪兽的场上怪兽效果（誓约自肃）。
function c3285551.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定时（chk==0）检查本回合是否已有被禁止的“非特殊召唤怪兽的场上怪兽效果发动”记录；计数必须为0，否则不能发动本卡。
	if chk==0 then return Duel.GetCustomActivityCount(3285551,tp,ACTIVITY_CHAIN)==0 end
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把特殊召唤的怪兽以外的场上的怪兽的效果发动。①：自己场上没有「勇者衍生物」存在的场合才能发动。在自己场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。自己场上没有「命运之旅路」存在的场合，可以再从卡组把1张「命运之旅路」在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(c3285551.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将这个“不能发动效果”的永续效果注册到决斗中，使它从此刻起对tp玩家适用，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 禁发效果的判定函数：若尝试发动的效果是怪兽效果且发动位置在主要怪兽区，且该怪兽不是以特殊召唤方式出场的怪兽（即非特殊召唤怪兽），则禁止发动。
function c3285551.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE)
end
-- 发动时应确认的合法处理条件：自己主要怪兽区有空位，且玩家tp能够特殊召唤1只「勇者衍生物」（天使族·地·4星·攻/守2000）；满足这些条件才可发动。
function c3285551.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时先确认自己主要怪兽区还有空余格子（可特殊召唤衍生物的空间），否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查玩家是否能特殊召唤参数为「勇者衍生物」的衍生物（天使族·地·4星·攻/守2000，衍生物类型），包括特殊召唤限制等判定。
		Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH) end
	-- 将本次连锁的操作信息登记为生成衍生物（CATEGORY_TOKEN），预计生成1只衍生物，供其他关联效果的时点/发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 将本次连锁的操作信息登记为特殊召唤（CATEGORY_SPECIAL_SUMMON），预计将1只怪兽特殊召唤到tp场上，供此类效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 过滤函数：用于检查场上是否存在表侧表示的「命运之旅路」（39568067）。
function c3285551.cfilter(c)
	return c:IsCode(39568067) and c:IsFaceup()
end
-- 过滤函数：用于从卡组中选出可以放置的「命运之旅路」（39568067），且该卡不属于不可使用的禁止卡。
function c3285551.setfilter(c)
	return c:IsCode(39568067) and not c:IsForbidden()
end
-- 效果处理的入口：先检查是否仍能满足特殊召唤勇者衍生物的条件（我方主要怪兽区有空格、玩家可以特殊召唤该衍生物），若不满足则直接终止处理。
function c3285551.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方主要怪兽区没有空格（<=0），则无法特殊召唤衍生物，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 如果玩家已不能特殊召唤「勇者衍生物」（可能受特殊召唤限制等影响），则直接结束处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH) then return end
	-- 创建1只编号为3285552的衍生物「勇者衍生物」，归属玩家tp，等待后续特殊召唤。
	local token=Duel.CreateToken(tp,3285552)
	-- 将刚创建的「勇者衍生物」以表侧表示特殊召唤到tp的怪兽区（不做召唤条件/苏生限制的额外检查）。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	-- 从己方卡组筛选出所有「命运之旅路」（非禁止卡），作为后续选择放置的候选组。
	local g=Duel.GetMatchingGroup(c3285551.setfilter,tp,LOCATION_DECK,0,nil)
	-- 检查己方魔法与陷阱区域不存在表侧表示的「命运之旅路」；若已存在则不能进行放置，对应原文“自己场上没有「命运之旅路」存在的场合”。
	if not Duel.IsExistingMatchingCard(c3285551.cfilter,tp,LOCATION_SZONE,0,1,nil)
		-- 同时要求己方魔法与陷阱区域有空位，且卡组中存在可放置的「命运之旅路」；全部满足才执行后续放置。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetCount()>0
		-- 弹出选择询问，让玩家决定是否从卡组把「命运之旅路」放置；选择“是”才继续。
		and Duel.SelectYesNo(tp,aux.Stringid(3285551,0)) then  --"是否从卡组把「命运之旅路」放置？"
		-- 中断当前效果处理，使特殊召唤「勇者衍生物」与后续放置「命运之旅路」被视为不同时点处理，以正确产生时点。
		Duel.BreakEffect()
		-- 在选择卡片前向玩家发送HINT_SELECTMSG提示（“请选择要放置到场上的卡”），并指定选择类型为HINTMSG_TOFIELD，用于选择要放置到魔陷区的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选中的「命运之旅路」移动到己方魔法与陷阱区域以表侧表示放置，并立刻适用其卡面效果（enable=true）。
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
