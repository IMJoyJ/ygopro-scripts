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
	-- 只要这张卡在魔法与陷阱区域存在，相同种族的怪兽在双方场上各自只能有1只表侧表示存在。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(24207889)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	-- 相同种族的怪兽在双方场上各自只能有1只表侧表示存在。
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
		-- 双方玩家在自身场上有相同种族的怪兽2只以上存在的场合，直到相同种族的怪兽变成1只为止必须送去墓地。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(c24207889.adjustop)
		-- 将全局调整效果ge1注册到决斗中，使每次规则调整时执行千查万别的同种族数量检查和送墓处理。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：判断怪兽是否为表侧表示、是否属于指定种族rc且状态为可生效（STATUS_EFFECT_ENABLED），用于筛选场上符合条件的表侧怪兽。
function c24207889.rmfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc) and c:IsStatus(STATUS_EFFECT_ENABLED)
end
-- 召唤/特殊召唤/反转召唤的限制判定：二重召唤或里侧表示的特殊召唤不受此限制；否则若场上（或目标控制者场上）已存在表侧表示且与要召唤怪兽相同种族的怪兽，则禁止这次表侧表示召唤/特殊召唤。
function c24207889.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumtype==SUMMON_TYPE_DUAL then return false end
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	local tp=sump
	if targetp then tp=targetp end
	-- 检查tp方场上是否存在至少1张表侧表示、种族与要召唤的怪兽相同的怪兽；若存在则返回true，禁止该表侧表示召唤/特殊召唤，从而维持同种族表侧怪兽最多1只。
	return Duel.IsExistingMatchingCard(c24207889.rmfilter,tp,LOCATION_MZONE,0,1,nil,c:GetRace())
end
-- 全局调整操作：若千查万别不在场则清理缓存并返回；若在场则跳过伤害计算阶段，分别统计双方场上的表侧怪兽，当某玩家某一种族的表侧怪兽超过1只时，由该玩家选择多余数量送去墓地，送墓后刷新并更新各族怪兽的缓存列表。
function c24207889.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家0是否受千查万别效果影响；若不受影响，说明该效果已失效，则清理记录的种族缓存并结束本次处理。
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
	-- 获取当前游戏阶段，用于判断是否处于伤害计算相关时点，避免在不利时机进行送墓处理。
	local phase=Duel.GetCurrentPhase()
	-- 若当前是伤害步骤且尚未计算伤害，或正处于伤害计算阶段，则直接返回，不进行送墓处理，避免干扰伤害计算。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local sg=Group.CreateGroup()
	for p=0,1 do
		-- 获取p玩家场上全部表侧表示怪兽，作为后续按种族分组检查和选择送墓的对象。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		local race=1
		while race<RACE_ALL do
			local rg=g:Filter(Card.IsRace,nil,race)
			local rc=rg:GetCount()
			if rc>1 then
				rg:Sub(c24207889[p][race]:Filter(Card.IsRace,nil,race))
				-- 向p玩家显示“请选择要送去墓地的卡”的提示，引导玩家在接下来的选择操作中选择要送去墓地的怪兽。
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local dg=rg:Select(p,rc-1,rc-1,nil)
				sg:Merge(dg)
			end
			race=race<<1
		end
	end
	if sg:GetCount()>0 then
		-- 将之前选择出的怪兽组sg以规则理由送到墓地，实现“必须送去墓地”的规则处理。
		Duel.SendtoGrave(sg,REASON_RULE)
		-- 刷新场上卡片信息，使刚被送去墓地的怪兽从场上消失的状态立即反映到其他效果判断中，避免后续判断使用过期数据。
		Duel.Readjust()
	end
	for p=0,1 do
		-- 再次获取p玩家场上表侧表示怪兽，用于在送墓后更新各表侧怪兽种族的缓存列表，为下次调整做好准备。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
		local race=1
		while race<RACE_ALL do
			c24207889[p][race]:Clear()
			c24207889[p][race]:Merge(g:Filter(Card.IsRace,nil,race))
			race=race<<1
		end
	end
end
