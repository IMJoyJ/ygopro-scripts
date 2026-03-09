--ソウル・オブ・スタチュー
-- 效果：
-- 这张卡发动后变成怪兽卡（岩石族·光·4星·攻1000/守1800）在自己的怪兽卡区域特殊召唤。只要这张卡在场上当作怪兽使用而存在，这张卡以外的当作怪兽使用的陷阱卡被对方破坏送去自己墓地的场合，可以不送去墓地在魔法与陷阱卡区域盖放。这张卡也当作陷阱卡使用。
function c49514333.initial_effect(c)
	-- 这张卡发动后变成怪兽卡（岩石族·光·4星·攻1000/守1800）在自己的怪兽卡区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c49514333.target)
	e1:SetOperation(c49514333.activate)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上当作怪兽使用而存在，这张卡以外的当作怪兽使用的陷阱卡被对方破坏送去自己墓地的场合，可以不送去墓地在魔法与陷阱卡区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetCondition(c49514333.repcon)
	e2:SetTarget(c49514333.reptg)
	e2:SetValue(c49514333.repval)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
end
-- 检查是否满足特殊召唤条件，包括场地空位和能否特殊召唤该怪兽
function c49514333.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡为怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,49514333,0,TYPES_EFFECT_TRAP_MONSTER,1000,1800,4,RACE_ROCK,ATTRIBUTE_LIGHT) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动时将此卡变为怪兽卡并特殊召唤到场上
function c49514333.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认是否可以特殊召唤此卡为怪兽
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,49514333,0,TYPES_EFFECT_TRAP_MONSTER,1000,1800,4,RACE_ROCK,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断此卡是否为特殊召唤（自身效果）
function c49514333.repcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤出被破坏送入墓地的陷阱怪兽卡片
function c49514333.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetDestination()==LOCATION_GRAVE and c:GetLeaveFieldDest()==0 and c:IsReason(REASON_DESTROY)
		and c:GetReasonPlayer()==1-tp and c:GetOwner()==tp and bit.band(c:GetOriginalType(),TYPE_TRAP)~=0 and c:IsCanTurnSet()
end
-- 处理是否使用效果，若选择使用则将符合条件的陷阱怪兽移动至魔法与陷阱区域并盖放
function c49514333.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(c49514333.repfilter,e:GetHandler(),tp)
		-- 判断是否有足够的魔法与陷阱区域来放置这些卡片
		return count>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=count
	end
	-- 询问玩家是否要使用「灵魂之像」的效果
	if Duel.SelectYesNo(tp,aux.Stringid(49514333,0)) then  --"是否要使用「灵魂之像」的效果？"
		local container=e:GetLabelObject()
		container:Clear()
		local g=eg:Filter(c49514333.repfilter,e:GetHandler(),tp)
		local tc=g:GetFirst()
		while tc do
			-- 将符合条件的陷阱怪兽移至魔法与陷阱区域
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			tc=g:GetNext()
		end
		-- 将这些陷阱怪兽变为里侧表示
		Duel.ChangePosition(g,POS_FACEDOWN)
		container:Merge(g)
		return true
	end
	return false
end
-- 返回该效果是否生效
function c49514333.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end
