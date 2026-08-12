--聖騎士と聖剣の巨城
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡直到下次的准备阶段除外，从自己的手卡·卡组·墓地把1张「圆桌的圣骑士」在自己的场地区域表侧表示放置。那之后，以下效果可以适用。
-- ●从自己的卡组·墓地把1只「阿托利斯」怪兽特殊召唤或把1张「圣剑」卡加入手卡。
-- ②：1回合1次，自己场上的「圣骑士」卡被战斗·效果破坏的场合，可以作为代替把自己场上1张装备卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动、代替破坏和主要阶段效果
function s.initial_effect(c)
	-- 记录该卡拥有「圆桌的圣骑士」卡名
	aux.AddCodeList(c,55742055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的「圣骑士」卡被战斗·效果破坏的场合，可以作为代替把自己场上1张装备卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。这张卡直到下次的准备阶段除外，从自己的手卡·卡组·墓地把1张「圆桌的圣骑士」在自己的场地区域表侧表示放置。那之后，以下效果可以适用。●从自己的卡组·墓地把1只「阿托利斯」怪兽特殊召唤或把1张「圣剑」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.rptg)
	e3:SetOperation(s.rpop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的「圣骑士」卡，用于判断是否可以发动代替破坏效果
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤满足条件的装备卡，用于判断是否可以发动代替破坏效果
function s.dfilter(c,e)
	return c:GetEquipTarget() and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 判断是否可以发动代替破坏效果，检查是否有装备卡和被破坏的「圣骑士」卡
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取所有可被破坏的装备卡
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_SZONE,0,nil,e)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp)
		and #g>0 end
	local c=e:GetHandler()
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 设置目标装备卡为即将被破坏的卡
		Duel.SetTargetCard(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数，将目标装备卡破坏
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备卡对象
	local tc=Duel.GetFirstTarget()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将目标装备卡以效果破坏的方式破坏
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 代替破坏效果的值函数，返回是否为「圣骑士」卡
function s.repval(e,c)
	return s.filter(c,e:GetHandlerPlayer())
end
-- 过滤满足条件的「圆桌的圣骑士」卡，用于选择放置到场上的卡
function s.pfilter(c,tp)
	return c:IsCode(55742055) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 判断是否可以发动①效果，检查是否能除外自身并检索「圆桌的圣骑士」卡
function s.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		-- 检查是否满足检索「圆桌的圣骑士」卡的条件
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
	-- 设置操作信息，表示将要除外该卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
-- 过滤满足条件的「阿托利斯」怪兽或「圣剑」卡，用于选择特殊召唤或加入手卡的卡
function s.sfilter(c,e,tp)
	-- 判断是否满足特殊召唤「阿托利斯」怪兽的条件
	if c:IsSetCard(0xa7) then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	elseif c:IsSetCard(0x207a) then return c:IsAbleToHand() end
	return false
end
-- ①效果的处理函数，将自身除外并放置「圆桌的圣骑士」卡，然后选择特殊召唤或加入手卡
function s.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将自身以除外形式移除，若失败则返回
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 or not c:IsLocation(LOCATION_REMOVED) then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	-- 注册准备阶段效果，用于在下次准备阶段将自身移回场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	e1:SetCountLimit(1)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	-- 注册准备阶段效果到玩家环境
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要放置到场上的「圆桌的圣骑士」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择一张「圆桌的圣骑士」卡放置到场地区域
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	-- 将选中的卡移动到场地区域，若失败则返回
	if not (tc and Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)) then return end
	-- 获取满足条件的「阿托利斯」怪兽或「圣剑」卡，用于选择特殊召唤或加入手卡
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 询问玩家是否选择特殊召唤或加入手卡
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选卡特殊召唤或加入手卡？"
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sc=tg:Select(tp,1,1,nil):GetFirst()
		-- 判断是否满足特殊召唤「阿托利斯」怪兽的条件
		local b1=sc:IsSetCard(0xa7) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=sc:IsSetCard(0x207a) and sc:IsAbleToHand()
		-- 根据选择的选项执行特殊召唤或加入手卡操作
		local op=aux.SelectFromOptions(tp,{b1,1152},{b2,1190})
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		if op==2 then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 确认对方看到加入手卡的卡
			Duel.ConfirmCards(1-tp,sc)
		-- 特殊召唤选中的「阿托利斯」怪兽
		else Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end
	end
end
-- 判断准备阶段效果是否触发的条件函数
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetOwner():GetFlagEffect(id)>0
end
-- 准备阶段效果的处理函数，将自身移回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场地区域的卡
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		-- 将场地区域的卡送去墓地
		Duel.SendtoGrave(fc,REASON_RULE)
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
	end
	-- 将自身移回场地区域
	Duel.MoveToField(e:GetOwner(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	e:Reset()
end
