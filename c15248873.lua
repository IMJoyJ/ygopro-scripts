--ポップルアップ
-- 效果：
-- 「弹出式翻页」在1回合只能发动1张。
-- ①：对方的场地区域有卡存在，自己的场地区域没有卡存在的场合才能发动。从卡组把1张场地魔法卡发动。
function c15248873.initial_effect(c)
	-- 注册卡牌效果，设置为发动时点，自由连锁，发动次数限制为1次（誓约次数），并设置条件、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15248873+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15248873.condition)
	e1:SetTarget(c15248873.target)
	e1:SetOperation(c15248873.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：自己场地区域没有卡，对方场地区域有卡
function c15248873.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：对方的场地区域有卡存在，自己的场地区域没有卡存在的场合才能发动
	return Duel.GetFieldCard(tp,LOCATION_FZONE,0)==nil and Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)~=nil
end
-- 过滤函数：筛选卡组中可发动的场地魔法卡
function c15248873.filter(c,tp)
	return c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 设置发动目标：检查卡组中是否存在满足条件的场地魔法卡，若不在阶段开始时则设置标签为1
function c15248873.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果原文：从卡组把1张场地魔法卡发动
	if chk==0 then return Duel.IsExistingMatchingCard(c15248873.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 若当前阶段未开始则设置标签为1，否则为0
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
end
-- 效果处理函数：提示选择场地魔法卡，若标签为1则注册标识效果，选择卡牌后处理发动逻辑
function c15248873.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(15248873,0))  --"请选择一张场地魔法卡"
	-- 若标签为1则注册标识效果，用于处理错时点
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	-- 从卡组选择一张满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,c15248873.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,15248873)
	if tc then
		-- 获取自己场地区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将场地区域的卡送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡特殊召唤到自己场地区域
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		-- 触发选中卡牌的发动时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
