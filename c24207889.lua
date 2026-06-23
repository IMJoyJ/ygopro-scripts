--センサー万別
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，相同种族的怪兽在双方场上各自只能有1只表侧表示存在。双方玩家在自身场上有相同种族的怪兽2只以上存在的场合，直到相同种族的怪兽变成1只为止必须送去墓地。
function c24207889.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，相同种族的怪兽在双方场上各自只能有1只表侧表示存在。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(24207889)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	-- 双方玩家在自身场上有相同种族的怪兽2只以上存在的场合，直到相同种族的怪兽变成1只为止必须送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c24207889.sumlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e6)
	if not c24207889.global_check then
		c24207889.global_check=true
		c24207889.is_empty=true
		c24207889[0]={}
		c24207889[1]={}
		local race=1
		while race<RACE_ALL do
			c24207889[0][race]=Group.CreateGroup()
			c24207889[0][race]:KeepAlive()
			c24207889[1][race]=Group.CreateGroup()
			c24207889[1][race]:KeepAlive()
			race=race<<1
		end
		-- 把效果e作为玩家player的效果注册给全局环境
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(c24207889.adjustop)
		-- 检索满足条件的卡片组
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数，检查以player来看的指定位置是否存在至少count张满足过滤条件f并且不等于ex的卡
function c24207889.rmfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc) and c:IsStatus(STATUS_EFFECT_ENABLED)
end
-- 将目标怪兽特殊召唤
function c24207889.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumtype==SUMMON_TYPE_DUAL then return false end
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	local tp=sump
	if targetp then tp=targetp end
	-- 返回值是实际被操作的数量
	return Duel.IsExistingMatchingCard(c24207889.rmfilter,tp,LOCATION_MZONE,0,1,nil,c:GetRace())
end
-- 刷新场上的卡的信息
function c24207889.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 返回以player来看的指定位置满足过滤条件f并且不等于ex的卡
	if not Duel.IsPlayerAffectedByEffect(0,24207889) then
		if not c24207889.is_empty then
			local race=1
			while race<RACE_ALL do
				c24207889[0][race]:Clear()
				c24207889[1][race]:Clear()
				race=race<<1
			end
			c24207889.is_empty=true
		end
		return
	end
	c24207889.is_empty=false
	-- 用于在伤害阶段检查是否已经计算了战斗伤害
	local phase=Duel.GetCurrentPhase()
	-- 返回当前的阶段
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local sg=Group.CreateGroup()
	for p=0,1 do
		-- 将目标怪兽特殊召唤
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		local race=1
		while race<RACE_ALL do
			local rg=g:Filter(Card.IsRace,nil,race)
			local rc=rg:GetCount()
			if rc>1 then
				rg:Sub(c24207889[p][race]:Filter(Card.IsRace,nil,race))
				-- 给玩家player发送hint_type类型的消息提示，提示内容为desc
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local dg=rg:Select(p,rc-1,rc-1,nil)
				sg:Merge(dg)
			end
			race=race<<1
		end
	end
	if sg:GetCount()>0 then
		-- 以reason原因把targets送去墓地
		Duel.SendtoGrave(sg,REASON_RULE)
		-- 刷新场上的卡的信息
		Duel.Readjust()
	end
	for p=0,1 do
		-- 返回以player来看的指定位置满足过滤条件f并且不等于ex的卡
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		local race=1
		while race<RACE_ALL do
			c24207889[p][race]:Clear()
			c24207889[p][race]:Merge(g:Filter(Card.IsRace,nil,race))
			race=race<<1
		end
	end
end
