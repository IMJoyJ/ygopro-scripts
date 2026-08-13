--潜海奇襲
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·墓地选1张「海」发动。
-- ②：场上有「海」存在的场合，表侧表示的这张卡得到以下效果。
-- ●1回合1次，把自己场上1只表侧表示的水属性怪兽直到结束阶段除外才能发动。这个回合，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
-- ●原本等级是5星以上的自己的水属性怪兽和对方怪兽进行战斗的伤害步骤开始时发动。那只对方怪兽破坏。
function c19089195.initial_effect(c)
	-- 将卡号22702055（「海」）登记为这张卡记载的卡名，用于关联「海」的卡名检索与判定。
	aux.AddCodeList(c,22702055)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·墓地选1张「海」发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c19089195.activate)
	c:RegisterEffect(e1)
	-- ●1回合1次，把自己场上1只表侧表示的水属性怪兽直到结束阶段除外才能发动。这个回合，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19089195,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(c19089195.econ)
	e2:SetCost(c19089195.remcost)
	e2:SetOperation(c19089195.remop)
	c:RegisterEffect(e2)
	-- ●原本等级是5星以上的自己的水属性怪兽和对方怪兽进行战斗的伤害步骤开始时发动。那只对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19089195,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c19089195.descon)
	e3:SetTarget(c19089195.destg)
	e3:SetOperation(c19089195.desop)
	c:RegisterEffect(e3)
end
-- 定义检索/选择「海」的过滤条件：卡名必须是「海」，且满足放置条件（是场地魔法或自己后场有空位），且该「海」的魔法卡发动效果当前可以发动。
function c19089195.filter(c,tp)
	-- 筛选卡名为「海」且：若是场地魔法则可以直接放置；否则要求己方魔陷区有空位。
	return c:IsCode(22702055) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 处理①效果：从手卡·墓地选择1张「海」并发动；若选择的是场地魔法则先按规则将已有场地卡送墓，再放置到场地区，否则放置到魔陷区，并执行其作为魔法卡发动时的使用次数、cost和发动时点处理。
function c19089195.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡·墓地中满足过滤条件且不受王家长眠之谷影响的「海」的集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19089195.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp)
	-- 若存在可发动的「海」且玩家选择“是”，则继续处理发动；否则不处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19089195,0)) then  --"是否把「海」发动？"
		-- 弹出选择提示：请选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从手卡·墓地选择1张满足条件的「海」并取得选中的卡。
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19089195.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			local field=tc:IsType(TYPE_FIELD)
			if field then
				-- 获取自己场地区现有的场地卡（用于后续替换处理）。
				local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				if fc then
					-- 按规则将已有的场地卡送去墓地（新场地魔法发动前旧场地必须离场）。
					Duel.SendtoGrave(fc,REASON_RULE)
					-- 中断当前效果处理，使后续放置新场地并发动成为独立处理，避免时点被抢占。
					Duel.BreakEffect()
				end
				-- 将选中的「海」表侧表示放置到自己场地区，并立即适用其效果。
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			else
				-- 若选中的「海」不是场地魔法，则表侧表示放置到自己魔陷区。
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if field then
				-- 对放置到场地区的「海」触发魔法卡发动时点（事件码4179255），使其发动处理正确进入连锁。
				Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
			end
		end
	end
end
-- e2的发动条件：场上有「海」存在，且本回合尚未使用过②效果（通过效果码19089195标记防止重复发动）。
function c19089195.econ(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“当前环境为「海」”且“自己本回合未发动过②效果”的判定结果。
	return Duel.IsEnvironment(22702055) and not Duel.IsPlayerAffectedByEffect(tp,19089195)
end
-- 代价筛选条件：自己场上表侧表示、水属性且可以作为代价除外的怪兽。
function c19089195.costfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价处理：选择自己场上1只表侧表示水属性怪兽，作为代价暂时除外，并设置结束阶段返回效果；被除外的若是衍生物则不返回。
function c19089195.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查阶段：确认自己场上存在满足除外代价条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19089195.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示：请选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1只满足条件的怪兽作为除外对象。
	local g=Duel.SelectMatchingCard(tp,c19089195.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽以“代价+暂时除外”方式除外；若除外成功，则继续设置结束阶段返回处理。
	if Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local rc=g:GetFirst()
		if rc:IsType(TYPE_TOKEN) then return end
		-- 把自己场上1只表侧表示的水属性怪兽直到结束阶段除外；这个回合，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetOperation(c19089195.retop)
		-- 注册结束阶段返回效果，使被暂时除外的怪兽在结束阶段返回场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段返回操作函数：将被暂时除外的怪兽返回场上。
function c19089195.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行返回：将被暂时除外的怪兽以离场前的表示形式返回场上。
	Duel.ReturnToField(e:GetLabelObject())
end
-- ②效果处理：给己方玩家添加本回合已使用②效果的标记，并让己方场上表侧表示的魔法·陷阱卡获得“不会被对方的效果破坏”的抗性，均持续到回合结束。
function c19089195.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(19089195)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册标记效果（code=19089195）给自己玩家，用于econ中防止同回合重复发动②效果。
	Duel.RegisterEffect(e0,tp)
	-- 这个回合，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设定保护对象为己方场上的魔法·陷阱卡（对应原文“表侧表示的魔法·陷阱卡”）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	-- 设定破坏抗性判定条件：当效果来自对方玩家时，己方表侧魔法·陷阱卡不会被对方的效果破坏。
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册破坏抗性效果，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- e3的发动条件：场上有「海」存在，且己方表侧表示的原等级5星以上水属性怪兽与对方怪兽进行战斗的伤害步骤开始时，将对方怪兽记录为破坏对象。
function c19089195.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前环境为「海」，否则该效果不能发动。
	if not Duel.IsEnvironment(22702055) then return false end
	-- 获取战斗中的己方怪兽和对方怪兽，用于判断是否满足条件。
	local tc,bc=Duel.GetBattleMonster(tp)
	if not tc or not bc then return false end
	if tc:IsFaceup() and tc:GetOriginalLevel()>=5 and tc:IsAttribute(ATTRIBUTE_WATER) then
		e:SetLabelObject(bc)
		return true
	else return false end
end
-- 目标设定：必发效果，直接允许发动，并登记要破坏的对方怪兽。
function c19089195.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 登记操作信息：本次连锁将破坏记录的对方怪兽1只。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果处理：若对方怪兽仍与战斗相关，则将其破坏。
function c19089195.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 以效果破坏对方怪兽。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
