--潜海奇襲
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·墓地选1张「海」发动。
-- ②：场上有「海」存在的场合，表侧表示的这张卡得到以下效果。
-- ●1回合1次，把自己场上1只表侧表示的水属性怪兽直到结束阶段除外才能发动。这个回合，自己场上的表侧表示的魔法·陷阱卡不会被对方的效果破坏。
-- ●原本等级是5星以上的自己的水属性怪兽和对方怪兽进行战斗的伤害步骤开始时发动。那只对方怪兽破坏。
function c19089195.initial_effect(c)
	-- 记录此卡与「海」卡名的关联
	aux.AddCodeList(c,22702055)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的手卡·墓地选1张「海」发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c19089195.activate)
	c:RegisterEffect(e1)
	-- ②：场上有「海」存在的场合，表侧表示的这张卡得到以下效果。
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
-- 过滤函数：检查是否为「海」卡且满足可发动条件
function c19089195.filter(c,tp)
	-- 检查是否为「海」卡或场上存在可用魔法陷阱区域
	return c:IsCode(22702055) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 检索满足条件的「海」卡组并提示玩家选择是否发动
function c19089195.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「海」卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19089195.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp)
	-- 判断是否有满足条件的「海」卡且玩家选择发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19089195,0)) then  --"是否把「海」发动？"
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择一张满足条件的「海」卡
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19089195.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			local field=tc:IsType(TYPE_FIELD)
			if field then
				-- 获取玩家场上已存在的场地卡
				local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				if fc then
					-- 将已存在的场地卡送去墓地
					Duel.SendtoGrave(fc,REASON_RULE)
					-- 中断当前效果处理
					Duel.BreakEffect()
				end
				-- 将「海」卡移动到场上场地区域
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			else
				-- 将「海」卡移动到场上魔法陷阱区域
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if field then
				-- 触发「海」卡的发动时效果
				Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
			end
		end
	end
end
-- 判断是否满足效果发动条件：场上有「海」且玩家未被效果影响
function c19089195.econ(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有「海」且玩家未被效果影响
	return Duel.IsEnvironment(22702055) and not Duel.IsPlayerAffectedByEffect(tp,19089195)
end
-- 过滤函数：检查是否为表侧表示的水属性怪兽且可作为除外费用
function c19089195.costfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足除外费用条件：场上存在1只表侧表示的水属性怪兽
function c19089195.remcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19089195.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择1只满足条件的水属性怪兽除外
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 将卡除外并设置返回效果
	local g=Duel.SelectMatchingCard(tp,c19089195.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置除外卡在结束阶段返回场上的效果
	if Duel.Remove(g,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local rc=g:GetFirst()
		if rc:IsType(TYPE_TOKEN) then return end
		-- 注册除外卡返回场上的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetOperation(c19089195.retop)
		-- 注册效果到玩家环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回除外的卡到场上
function c19089195.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
-- 设置魔法陷阱卡不会被对方效果破坏的效果
function c19089195.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置魔法陷阱卡不会被对方效果破坏的效果
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(19089195)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家环境
	Duel.RegisterEffect(e0,tp)
	-- 设置魔法陷阱卡不会被对方效果破坏的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置目标为魔法陷阱卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	-- 设置效果值为不受对方效果破坏
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否满足破坏效果发动条件：场上有「海」且战斗怪兽满足等级和属性条件
function c19089195.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有「海」
	if not Duel.IsEnvironment(22702055) then return false end
	-- 获取战斗中的怪兽
	local tc,bc=Duel.GetBattleMonster(tp)
	if not tc or not bc then return false end
	if tc:IsFaceup() and tc:GetOriginalLevel()>=5 and tc:IsAttribute(ATTRIBUTE_WATER) then
		e:SetLabelObject(bc)
		return true
	else return false end
end
-- 设置破坏效果的目标
function c19089195.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 设置操作信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 执行破坏效果
function c19089195.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
