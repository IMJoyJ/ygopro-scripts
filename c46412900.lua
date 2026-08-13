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
	-- ①：这个方法让这张卡特殊召唤时才能发动。给与对方为除外状态的炎族怪兽数量×500伤害。那之后，可以从卡组把1张「火山」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46412900,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c46412900.damcon)
	e2:SetTarget(c46412900.damtg)
	e2:SetOperation(c46412900.damop)
	c:RegisterEffect(e2)
	-- ②：每次对方把怪兽特殊召唤给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c46412900.damcon2)
	e3:SetOperation(c46412900.damop2)
	c:RegisterEffect(e3)
end
-- 筛选可作为特殊召唤除外代价的卡：自己场上表侧表示或墓地的卡，且满足（炎族怪兽）或（「烈焰加农炮」卡）。
function c46412900.sprfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
		and (c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0xb9))
end
-- 检查所选代价组是否合法：除外后自己必须有怪兽区可用，并且（3张全部为炎族怪兽）或（1张为「烈焰加农炮」卡）。
function c46412900.gcheck(g,tp)
	-- 判定将这些卡除外后自己场上是否仍有可用的怪兽区，以保证能特殊召唤。
	return Duel.GetMZoneCount(tp,g)>0
		and (#g==3 and g:FilterCount(Card.IsRace,nil,RACE_PYRO)==3
			or #g==1 and g:FilterCount(Card.IsSetCard,nil,0xb9)==1)
end
-- 特殊召唤手续的条件：从自己场上（表侧表示）和墓地寻找可成为代价的卡，检查能否选出1张「烈焰加农炮」卡或3只炎族怪兽，且除外后场地足够。
function c46412900.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方场上（表侧表示）和墓地中所有符合过滤条件的卡，排除本卡自身（要特殊召唤的卡）。
	local g=Duel.GetMatchingGroup(c46412900.sprfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,e:GetHandler())
	return g:CheckSubGroup(c46412900.gcheck,1,3,tp)
end
-- 特殊召唤手续的选代价处理：让玩家从符合条件的己方场上（表侧表示）和墓地卡片中，选出1张「烈焰加农炮」卡或3只炎族怪兽作为除外素材，并保存该组卡供后续除外使用。
function c46412900.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可作为除外代价的候选卡组（己方场上表侧表示·墓地中符合过滤条件，且不包含本卡自身）。
	local g=Duel.GetMatchingGroup(c46412900.sprfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,e:GetHandler())
	-- 向玩家显示“请选择要除外的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c46412900.gcheck,true,1,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 实际执行特殊召唤手续：取出之前选择的代价卡组，将其表侧表示除外，从而完成从手卡·墓地的特殊召唤。
function c46412900.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的代价卡组以表侧表示除外，除外原因是特殊召唤手续。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判定本次特殊召唤是否由本卡自身的规则召唤方式（SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）完成，是则①可以发动。
function c46412900.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选除外状态下表侧表示的炎族怪兽，用于计算①的伤害数量。
function c46412900.damfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsFaceup()
end
-- 筛选卡组中满足可盖放条件的「火山」陷阱卡（字段0x32）。
function c46412900.scfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x32) and c:IsSSetable()
end
-- ①的发动目标判定：检查除外区是否有表侧炎族怪兽；计算数量×500并登记为给对方的效果伤害操作信息。
function c46412900.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前判定：确认除外区存在至少1张表侧表示的炎族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c46412900.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 统计双方除外区域表侧表示的炎族怪兽总数，乘以500得到伤害值。
	local val=Duel.GetMatchingGroupCount(c46412900.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)*500
	-- 将伤害数值登记到连锁操作信息中，指定伤害目标为对方玩家，类别为伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
-- ①的效果处理：造成“除外炎族怪兽数量×500”的伤害；若伤害实际生效且卡组有可盖放的「火山」陷阱卡，在玩家同意后中断时点，从卡组选1张盖放到自己场上。
function c46412900.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前双方除外区表侧炎族怪兽数量×500的伤害数值。
	local val=Duel.GetMatchingGroupCount(c46412900.damfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)*500
	-- 对对方玩家造成val点效果伤害，并判断是否造成成功（返回值非0）。
	if Duel.Damage(1-tp,val,REASON_EFFECT)~=0
		-- 检查卡组中是否存在至少1张可盖放的「火山」陷阱卡。
		and Duel.IsExistingMatchingCard(c46412900.scfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问己方玩家是否将1张「火山」陷阱卡在自己场上盖放。
		and Duel.SelectYesNo(tp,aux.Stringid(46412900,2)) then  --"是否把1张「火山」陷阱卡在自己场上盖放？"
			-- 中断当前连锁，使伤害处理与后续盖放处理分开，对应“那之后”的时点。
			Duel.BreakEffect()
			-- 显示“请选择要盖放的卡”的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从己方卡组中选择1张可盖放的「火山」陷阱卡。
			local g=Duel.SelectMatchingCard(tp,c46412900.scfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的「火山」陷阱卡在自己的魔法与陷阱区里侧表示盖放。
			Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤条件：判断怪兽特殊召唤的玩家是否为指定玩家，用于检测“对方把怪兽特殊召唤”。
function c46412900.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 效果②触发条件：本次特殊召唤成功的怪兽中存在由对方玩家特殊召唤的怪兽。
function c46412900.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c46412900.cfilter,1,nil,1-tp)
end
-- 效果②处理：展示本卡动画，给对方玩家造成500点伤害。
function c46412900.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示本卡的发动动画提示。
	Duel.Hint(HINT_CARD,0,46412900)
	-- 给对方玩家造成500点效果伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
