--活路への希望
-- 效果：
-- ①：自己基本分比对方少1000以上的场合，支付1000基本分才能发动。双方基本分差每有2000，自己从卡组抽1张。
function c80036543.initial_effect(c)
	-- ①：自己基本分比对方少1000以上的场合，支付1000基本分才能发动。双方基本分差每有2000，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c80036543.condition)
	e1:SetCost(c80036543.cost)
	e1:SetTarget(c80036543.target)
	e1:SetOperation(c80036543.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查自己基本分是否比对方少1000以上
function c80036543.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己当前基本分是否小于等于对方基本分减去1000
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-1000
end
-- 定义发动代价函数：支付1000基本分
function c80036543.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动时，检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 定义效果的目标确认与合法性检查函数，计算支付代价后的基本分差并检查是否能抽卡
function c80036543.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若不是正常发动（如被其他卡复制效果且未支付代价），直接根据当前基本分差检查是否能抽对应数量的卡
		if e:GetLabel()==0 then return Duel.IsPlayerCanDraw(tp,math.floor(math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))/2000)) end
		e:SetLabel(0)
		local cost=1000
		-- 获取影响玩家基本分支付代价的所有效果
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_LPCOST_CHANGE)}
		for _,te in ipairs(ce) do
			local con=te:GetCondition()
			local val=te:GetValue()
			if (not con or con(te)) then
				cost=val(te,e,tp,1000)
			end
		end
		-- 计算扣除实际支付代价后，自己预期的基本分
		local lp=Duel.GetLP(tp)-cost
		-- 检查在预期基本分差下，玩家是否能抽对应数量的卡
		return Duel.IsPlayerCanDraw(tp,math.floor(math.abs(lp-Duel.GetLP(1-tp))/2000))
	end
	-- 设置效果处理信息：抽卡，数量为当前基本分差除以2000的向下取整值
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,math.floor(math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))/2000))
end
-- 定义效果处理函数：计算双方基本分差并让玩家抽对应数量的卡
function c80036543.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前的基本分
	local p1=Duel.GetLP(tp)
	-- 获取对方当前的基本分
	local p2=Duel.GetLP(1-tp)
	local s=p2-p1
	if s<0 then s=p1-p2 end
	local d=math.floor(s/2000)
	-- 执行抽卡操作，让玩家抽对应数量的卡
	Duel.Draw(tp,d,REASON_EFFECT)
end
