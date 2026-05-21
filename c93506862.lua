--リチュア・ヴァニティ
-- 效果：
-- 自己的主要阶段时，把这张卡从手卡丢弃才能发动。这个回合，对方不能对应名字带有「遗式」的仪式魔法卡的发动把魔法·陷阱·效果怪兽的效果发动，名字带有「遗式」的仪式怪兽仪式召唤成功时，对方不能把魔法·陷阱·效果怪兽的效果发动。
function c93506862.initial_effect(c)
	-- 自己的主要阶段时，把这张卡从手卡丢弃才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93506862,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c93506862.cost)
	e1:SetOperation(c93506862.operation)
	c:RegisterEffect(e1)
end
-- 定义发动的代价函数，检查自身是否可以丢弃并执行丢弃操作
function c93506862.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义效果处理函数，注册三个在不同时点触发的全局效果以实现回合内的限制效果
function c93506862.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能对应名字带有「遗式」的仪式魔法卡的发动把魔法·陷阱·效果怪兽的效果发动
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c93506862.chainop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于限制对方对应「遗式」仪式魔法卡发动进行连锁的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 名字带有「遗式」的仪式怪兽仪式召唤成功时，对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c93506862.sucop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于检测「遗式」仪式怪兽是否仪式召唤成功的全局效果
	Duel.RegisterEffect(e2,tp)
	-- 名字带有「遗式」的仪式怪兽仪式召唤成功时，对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(c93506862.cedop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetLabelObject(e2)
	-- 注册用于在连锁结束时限制对方在仪式召唤成功时发动效果的全局效果
	Duel.RegisterEffect(e3,tp)
end
-- 在有效果发动时触发，若该效果是「遗式」仪式魔法卡的发动，则限制对方的连锁
function c93506862.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0x3a) and rc:IsType(TYPE_RITUAL) then
		-- 设置连锁限制，使对方不能对应当前效果的发动进行连锁
		Duel.SetChainLimit(c93506862.chainlm)
	end
end
-- 定义连锁限制条件，仅允许发动该效果的玩家进行连锁（即对方不能连锁）
function c93506862.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤出名字带有「遗式」且是通过仪式召唤特殊召唤成功的仪式怪兽
function c93506862.sucfilter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_RITUAL) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 在有怪兽特殊召唤成功时触发，若其中包含「遗式」仪式怪兽的仪式召唤，则将效果标记设为1
function c93506862.sucop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c93506862.sucfilter,1,nil) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 在连锁结束时触发，若满足「遗式」仪式怪兽仪式召唤成功的条件，则限制对方直到连锁结束前不能发动效果
function c93506862.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否仍处于特殊召唤成功的时点，且之前检测到有「遗式」仪式怪兽仪式召唤成功
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 then
		-- 设置连锁限制直到连锁结束，使对方不能发动任何卡的效果
		Duel.SetChainLimitTillChainEnd(c93506862.chainlm)
	end
end
