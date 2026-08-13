--ワーム・ベイト
-- 效果：
-- 这张卡发动的回合，自己不能把3·4星的怪兽召唤·特殊召唤。
-- ①：自己场上有昆虫族怪兽存在的场合才能发动。在自己场上把2只「虫衍生物」（昆虫族·地·1星·攻/守0）特殊召唤。
function c43140791.initial_effect(c)
	-- 这张卡发动的回合，自己不能把3·4星的怪兽召唤·特殊召唤。①：自己场上有昆虫族怪兽存在的场合才能发动。在自己场上把2只「虫衍生物」（昆虫族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c43140791.condition)
	e1:SetCost(c43140791.cost)
	e1:SetTarget(c43140791.target)
	e1:SetOperation(c43140791.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，记录玩家本回合是否进行过3·4星怪兽的召唤（不包含覆盖）；若进行过则计数为1，用于cost检查。
	Duel.AddCustomActivityCounter(43140791,ACTIVITY_SUMMON,c43140791.counterfilter)
	-- 注册一个自定义活动计数器，记录玩家本回合是否进行过3·4星怪兽的特殊召唤；若进行过则计数为1，用于cost检查。
	Duel.AddCustomActivityCounter(43140791,ACTIVITY_SPSUMMON,c43140791.counterfilter)
end
-- 计数器过滤函数：若召唤的怪兽不是3·4星则返回true（允许操作且不增加计数）；若怪兽是3·4星则返回false，使对应活动的计数器加1，以此记录本回合是否召唤/特殊召唤过3·4星怪兽。
function c43140791.counterfilter(c)
	return not c:IsLevel(3,4)
end
-- 过滤函数：判断怪兽是否为表侧表示且昆虫族，用于检查自己场上是否存在表侧昆虫族怪兽。
function c43140791.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 发动条件函数：检查自己场上是否存在至少1只表侧表示的昆虫族怪兽。
function c43140791.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测玩家自己场上主要怪兽区是否存在满足cfilter条件的表侧昆虫族怪兽（数量至少1），存在则满足发动条件。
	return Duel.IsExistingMatchingCard(c43140791.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 代价函数：检查本回合玩家是否没有进行过3·4星怪兽的召唤和特殊召唤（通过自定义计数器判断），若满足则执行代价：给玩家附加本回合不能召唤/特殊召唤3·4星怪兽的誓约效果。
function c43140791.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检测（chk==0）：如果本回合玩家进行过3·4星怪兽的召唤（计数器不为0），则代价不满足，返回false；否则继续检查特殊召唤计数器。
	if chk==0 then return Duel.GetCustomActivityCount(43140791,tp,ACTIVITY_SUMMON)==0
		-- 同时要求本回合没有进行过3·4星怪兽的特殊召唤；两个条件都满足才返回true作为代价可支付。
		and Duel.GetCustomActivityCount(43140791,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能把3·4星的怪兽召唤·特殊召唤。①：自己场上有昆虫族怪兽存在的场合才能发动。在自己场上把2只「虫衍生物」（昆虫族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c43140791.sumlimit)
	-- 将“不能特殊召唤3·4星怪兽”的誓约效果注册到场上，对控制者tp生效；该效果在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将“不能召唤3·4星怪兽”的誓约效果注册到场上，对控制者tp生效；该效果在结束阶段重置。
	Duel.RegisterEffect(e2,tp)
end
-- 限制过滤函数：被限制的怪兽为等级3或等级4的怪兽；若怪兽的等级是3或4，则不能进行对应的召唤/特殊召唤。
function c43140791.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevel(3,4)
end
-- 发动目标函数（实际不取对象）：检测发动条件，包括青眼精灵龙没有封双方同时特招2只以上、自己的主要怪兽区空位多于1个、且玩家能够特殊召唤‘虫衍生物’token。
function c43140791.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己主要怪兽区的可用空位数量大于1，以便特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认玩家tp能够以表侧表示特殊召唤2只‘虫衍生物’（token，昆虫族·地·1星·攻/守0）到自己的主要怪兽区；若不可则不能发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43140792,0x3e,TYPES_TOKEN_MONSTER,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 向连锁处理信息中登记：本次效果将生成2只衍生物（token），类别为CATEGORY_TOKEN，目标玩家和位置未知（处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 向连锁处理信息中登记：本次效果将进行2只怪兽的特殊召唤，类别为CATEGORY_SPECIAL_SUMMON，同样不指定具体卡（因为衍生物在效果处理时才生成）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理函数：再次确认青眼精灵龙效果未生效、主要怪兽区有2个以上空位且能特殊召唤token后，连续特殊召唤2只‘虫衍生物’token到自己的主要怪兽区。
function c43140791.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时检查自己主要怪兽区的可用空位仍大于1；若空位不足则后续无法特殊召唤2只衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 效果处理时再次确认玩家可以特殊召唤‘虫衍生物’token；若可以则进入生成token的循环。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43140792,0x3e,TYPES_TOKEN_MONSTER,0,0,1,RACE_INSECT,ATTRIBUTE_EARTH) then
		for i=1,2 do
			-- 创建一只‘虫衍生物’token（卡号43140792），用于后续特殊召唤。
			local token=Duel.CreateToken(tp,43140792)
			-- 以表侧表示将token特殊召唤到自己场上；该操作作为连续特殊召唤的一部分，暂不完成特殊召唤流程。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 结束连续特殊召唤处理，完成所有token的特殊召唤；若有召唤被干扰则在此统一处理。
		Duel.SpecialSummonComplete()
	end
end
