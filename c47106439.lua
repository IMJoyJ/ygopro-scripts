--ヴィジョン・リチュア
-- 效果：
-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把1只「遗式」仪式怪兽加入手卡。
function c47106439.initial_effect(c)
	-- ②：把这张卡从手卡丢弃才能发动。从卡组把1只「遗式」仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47106439,0))  --"仪式怪兽加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c47106439.cost)
	e1:SetTarget(c47106439.target)
	e1:SetOperation(c47106439.operation)
	c:RegisterEffect(e1)
	-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(c47106439.rlevel)
	c:RegisterEffect(e2)
end
-- 作为EFFECT_RITUAL_LEVEL的Value函数：当用于水属性仪式怪兽的仪式召唤时，将本卡等级编码为高16位、仪式怪兽等级为低16位返回，使本卡可作为等量数值的解放；否则只返回本卡等级。
function c47106439.rlevel(e,c)
	-- 获取效果持有者（本卡）的等级，并通过aux.GetCappedLevel限制不会超过引擎安全上限，作为基础等级。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 发动②效果的代价函数：通过IsDiscardable检测手牌中的本卡能否丢弃，若可以则将其丢弃作为发动代价。
function c47106439.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将本卡从手牌送去墓地，丢弃原因同时标记为代价和丢弃，即完成“从手卡丢弃”的代价支付。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：筛选出卡组中属于「遗式」系列、是仪式怪兽（0x81为怪兽类型+仪式类型）且能够加入手牌的卡片。
function c47106439.filter(c)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- ②效果的发动目标函数：检查卡组中是否存在符合条件的「遗式」仪式怪兽，并设置操作信息，为后续从卡组加入手牌效果做准备。
function c47106439.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查（chk==0）：确认卡组中是否存在至少1张满足c47106439.filter的「遗式」仪式怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c47106439.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：本次效果处理涉及将卡组中的1张卡加入手牌（CATEGORY_TOHAND），目标位置为卡组、数量为1，供相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：从卡组挑选1只符合条件的「遗式」仪式怪兽加入手牌，并让对方确认该卡片。
function c47106439.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片提示，提示文本为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己的卡组中选出1张符合c47106439.filter的「遗式」仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,c47106439.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中卡送去持有者的手牌，操作原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手牌的卡片展示给对方玩家确认，以符合卡牌效果处理流程。
		Duel.ConfirmCards(1-tp,g)
	end
end
