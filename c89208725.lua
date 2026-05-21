--メタバース
-- 效果：
-- ①：从卡组选1张场地魔法卡加入手卡或在自己场上发动。
function c89208725.initial_effect(c)
	-- ①：从卡组选1张场地魔法卡加入手卡或在自己场上发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89208725.target)
	e1:SetOperation(c89208725.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：卡组中的场地魔法卡，且满足能加入手卡或能在场上发动
function c89208725.filter(c,tp)
	return c:IsType(TYPE_FIELD) and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
-- 效果发动时的目标选择与检测
function c89208725.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在符合条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c89208725.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 检查当前是否处于阶段开始时（如抽卡阶段开始时），并设置标记以处理特殊时点发动限制
	if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
	-- 设置操作信息，表示该效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择场地魔法卡加入手卡或在场上发动
function c89208725.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 若在非活动时点发动，注册临时标记以允许在此时点检索/选择场地魔法
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	-- 让玩家从卡组选择1张符合条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c89208725.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 重置临时标记
	Duel.ResetFlagEffect(tp,15248873)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		local b1=tc:IsAbleToHand()
		-- 若在非活动时点发动，再次注册临时标记以检测该场地魔法是否可发动
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
		local b2=te:IsActivatable(tp,true,true)
		-- 重置临时标记
		Duel.ResetFlagEffect(tp,15248873)
		-- 如果可以加入手卡，且（不能在场上发动 或 玩家选择“加入手卡”选项），则执行加入手卡处理
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
			-- 将选择的场地魔法卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 获取自己场地区域现有的场地魔法卡
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				-- 根据规则，将原本存在的场地魔法卡送去墓地
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果，使后续的场地发动处理不与送去墓地同时进行
				Duel.BreakEffect()
			end
			-- 将选择的场地魔法卡在自己的场地区域表侧表示放置（发动）
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发场地魔法卡发动的相关时点事件
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
