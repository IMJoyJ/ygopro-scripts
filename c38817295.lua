--月女神の至天
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。对方场上的怪兽数量比自己场上的怪兽多的场合，可以从以下效果选择1个发动。●支付800的倍数的基本分，以最多有对方场上的表侧表示怪兽数量的场上的卡为对象才能发动（每有1张支付800基本分）。那些卡的效果直到回合结束时无效。●对方手卡·墓地的怪兽的效果发动时才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方场上的怪兽数量比自己场上的怪兽多
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 比较双方场上的怪兽数量
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 效果目标：选择分支1或分支2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查对象是否为场上可无效的卡且非自身
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and aux.NegateAnyFilter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在可无效的卡
	local b1=Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查对方场上是否存在表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 检查本回合是否未发动过分支1且LP足够支付800
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0 and Duel.CheckLPCost(tp,800))
	local b2=false
	local og=Group.CreateGroup()
	-- 获取当前连锁序号
	local ch=Duel.GetCurrentChain()
	if e:GetHandler():IsStatus(STATUS_CHAINING) then ch=ch-1 end
	-- 检查是否存在连锁且本回合未发动过分支2
	if ch>0 and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0) then
		-- 获取连锁来源信息
		local tsp,tse,loc=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
		if tsp and tse and loc then
			og:AddCard(tse:GetHandler())
			b2=tsp==1-tp and tse:IsActiveType(TYPE_MONSTER)
				and (LOCATION_HAND+LOCATION_GRAVE)&loc~=0
				-- 检查该连锁是否可以被无效
				and Duel.IsChainDisablable(ev)
		end
	end
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 玩家选择发动的效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 记录本回合已使用分支1
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 计算可选择对象数量上限
		local ct=math.min(math.floor(Duel.GetLP(tp)/800),Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil))
		-- 提示选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择场上要无效的卡作为对象
		local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
		if e:IsCostChecked() then
			-- 支付对应数量×800LP的代价
			Duel.PayLPCost(tp,g:GetCount()*800)
		end
		-- 设置无效效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 记录本回合已使用分支2
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetProperty(0)
		end
		-- 设置无效连锁的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,og,1,0,0)
	end
end
-- 效果处理：根据分支使卡片效果无效或使连锁发动无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local c=e:GetHandler()
		-- 获取与连锁有关的目标卡片组
		local dg=Duel.GetTargetsRelateToChain()
		-- 遍历所有目标卡片
		for tc in aux.Next(dg) do
			-- 无效与目标卡相关的连锁
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标卡的效果直到回合结束时无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标卡发动的效果直到回合结束时无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使陷阱怪兽效果直到回合结束时无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	elseif e:GetLabel()==2 then
		-- 获取当前连锁序号
		local ch=Duel.GetCurrentChain()
		-- 使对方在手卡·墓地发动的怪兽效果无效
		Duel.NegateEffect(ch-1)
	end
end
