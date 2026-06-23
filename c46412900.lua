--ヴォルカニック・エンペラー
-- 效果：
-- 这张卡不能通常召唤。从自己的场上（表侧表示）·墓地把3只炎族怪兽或1张「烈焰加农炮」卡除外的场合才能从手卡·墓地特殊召唤。自己对「火山帝皇」1回合只能有1次特殊召唤。
-- ①：这个方法让这张卡特殊召唤时才能发动。给与对方为除外状态的炎族怪兽数量×500伤害。那之后，可以从卡组把1张「火山」陷阱卡在自己场上盖放。
-- ②：每次对方把怪兽特殊召唤给与对方500伤害。
function c46412900.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(46412900)
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 从自己的场上（表侧表示）·墓地把3只炎族怪兽或1张「烈焰加农炮」卡除外的场合才能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46412900,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c46412900.sprcon)
	e1:SetTarget(c46412900.sprtg)
	e1:SetOperation(c46412900.sprop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法让这张卡特殊召唤时才能发动。给与对方为除外状态的炎族怪兽数量×500伤害。那之后，可以从卡组把1张「火山」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46412900,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c46412900.damcon)
	e2:SetTarget(c46412900.damtg)
	e2:SetOperation(c46412900.damop)
	c:RegisterEffect(e2)
	-- 每次对方把怪兽特殊召唤给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c46412900.damcon2)
	e3:SetOperation(c46412900.damop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，返回满足条件的卡：表侧表示、可以作为除外的cost、是炎族怪兽或烈焰加农炮卡。
function c46412900.sprfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
		and (c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0xb9))
end
-- 检查所选卡组是否满足特殊召唤条件：有足够怪兽区且数量为3张时全部为炎族，或数量为1张时为烈焰加农炮卡。
function c46412900.gcheck(g,tp)
	-- 检查玩家场上是否有可用的怪兽区。
	return Duel.GetMZoneCount(tp,g)>0
		and (#g==3 and g:FilterCount(Card.IsRace,nil,RACE_PYRO)==3
			or #g==1 and g:FilterCount(Card.IsSetCard,nil,0xb9)==1)
end
-- 判断特殊召唤条件是否满足：获取符合条件的卡组并检查是否存在满足gcheck条件的子集。
function c46412900.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足特殊召唤过滤条件的卡组，包括墓地和场上的卡。
	local g=Duel.GetMatchingGroup(c46412900.sprfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,e:GetHandler())
	return g:CheckSubGroup(c46412900.gcheck,1,3,tp)
end
-- 选择满足条件的卡组作为除外对象，并设置标签记录所选卡组。
function c46412900.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤过滤条件的卡组，包括墓地和场上的卡。
	local g=Duel.GetMatchingGroup(c46412900.sprfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,e:GetHandler())
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c46412900.gcheck,true,1,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作：将指定卡组除外。
function c46412900.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定卡组从游戏中除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断效果是否由特殊召唤方式发动：确认召唤类型为特殊召唤且为自身效果。
function c46412900.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数，返回满足条件的卡：表侧表示、是炎族怪兽。
function c46412900.damfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsFaceup()
end
-- 过滤函数，返回满足条件的卡：是陷阱卡、是火山系列、可以盖放。
function c46412900.scfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x32) and c:IsSSetable()
end
-- 设置伤害效果的目标和数值：统计除外状态的炎族怪兽数量并计算总伤害值。
function c46412900.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足伤害过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46412900.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 统计除外状态的炎族怪兽数量并乘以500作为伤害值。
	local val=Duel.GetMatchingGroupCount(c46412900.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)*500
	-- 设置连锁操作信息，指定将要造成伤害的目标和数值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
-- 执行伤害效果：计算伤害值并对对方造成伤害，若满足条件则可选择盖放火山陷阱卡。
function c46412900.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计除外状态的炎族怪兽数量并乘以500作为伤害值。
	local val=Duel.GetMatchingGroupCount(c46412900.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)*500
	-- 对对方造成伤害，若伤害值不为0则继续执行后续操作。
	if Duel.Damage(1-tp,val,REASON_EFFECT)~=0
		-- 检查卡组中是否存在火山陷阱卡。
		and Duel.IsExistingMatchingCard(c46412900.scfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择盖放火山陷阱卡。
		and Duel.SelectYesNo(tp,aux.Stringid(46412900,2)) then  --"是否把1张「火山」陷阱卡在自己场上盖放？"
			-- 中断当前效果处理，使之后的效果视为不同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从卡组中选择一张火山陷阱卡。
			local g=Duel.SelectMatchingCard(tp,c46412900.scfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选定的火山陷阱卡在自己场上盖放。
			Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤函数，返回满足条件的卡：是对方召唤的怪兽。
function c46412900.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断是否满足触发条件：检查是否有对方特殊召唤成功的怪兽。
function c46412900.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c46412900.cfilter,1,nil,1-tp)
end
-- 执行伤害效果：对对方造成500点伤害。
function c46412900.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，显示火山帝皇发动了效果。
	Duel.Hint(HINT_CARD,0,46412900)
	-- 对对方造成500点伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
