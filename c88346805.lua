--斬リ番
-- 效果：
-- ①：卡的效果10次以上发动的回合才能把这张卡发动。发动后变成效果怪兽（电子界族·暗·10星·攻/守3000）在怪兽区域特殊召唤（也当作陷阱卡使用）。这个效果特殊召唤的这张卡在自己结束阶段在自己的魔法与陷阱区域盖放。
-- ②：1回合1次，这张卡在怪兽区域存在，对方把卡的效果发动时才能发动。对方场上的卡全部破坏。那之后，这张卡在自己的魔法与陷阱区域盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：卡的效果10次以上发动的回合才能把这张卡发动。发动后变成效果怪兽（电子界族·暗·10星·攻/守3000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 添加用于记录卡的效果发动次数的自定义计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)
	-- ②：1回合1次，这张卡在怪兽区域存在，对方把卡的效果发动时才能发动。对方场上的卡全部破坏。那之后，这张卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果①发动的条件判定函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定双方玩家在本回合中发动卡的效果的合计次数是否在10次以上
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)+Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>9
end
-- 效果①发动的目标与合法性检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将该卡作为特定属性、种族、攻守和等级的效果怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,3000,3000,10,RACE_CYBERSE,ATTRIBUTE_DARK) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①发动后的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e)
		-- 检查该卡是否仍与效果关联，且玩家是否仍能将其作为怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,3000,3000,10,RACE_CYBERSE,ATTRIBUTE_DARK)) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 尝试将该卡作为自身效果特殊召唤，若成功则注册结束阶段盖放的效果
	if Duel.SpecialSummonStep(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡在自己结束阶段在自己的魔法与陷阱区域盖放。②：1回合1次，这张卡在怪兽区域存在，对方把卡的效果发动时才能发动。对方场上的卡全部破坏。那之后，这张卡在自己的魔法与陷阱区域盖放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCondition(s.setcon)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的处理流程
	Duel.SpecialSummonComplete()
end
-- 结束阶段盖放效果的条件判定函数
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段盖放效果的处理函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若该卡是通过自身效果特殊召唤的，则将其转为里侧守备表示（在魔法与陷阱区域盖放）
	if c:IsSummonType(SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF) then Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE) end
end
-- 效果②发动的条件判定函数，判定是否为对方发动了卡的效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 效果②发动的目标与合法性检查函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 检查对方场上是否有卡、自己魔法与陷阱区域是否有空位，且自身是否可以盖放
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsCanTurnSet() end
	-- 设置破坏的操作信息，目标为对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置表示形式变更（盖放）的操作信息，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果②发动后的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 破坏对方场上的卡，并检查是否成功破坏以及自身是否仍在怪兽区域存在
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
		-- 将自身转为里侧守备表示（在魔法与陷阱区域盖放）
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
