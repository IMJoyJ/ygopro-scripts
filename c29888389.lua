--シャドウ・リチュア
-- 效果：
-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把1张「遗式」仪式魔法卡加入手卡。
function c29888389.initial_effect(c)
	-- 效果原文内容：②：把这张卡从手卡丢弃才能发动。从卡组把1张「遗式」仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29888389,0))  --"仪式魔法卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c29888389.cost)
	e1:SetTarget(c29888389.target)
	e1:SetOperation(c29888389.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(c29888389.rlevel)
	c:RegisterEffect(e2)
end
-- 当仪式怪兽为水属性时，返回该卡等级左移16位加上该仪式怪兽等级的数值，否则返回该卡等级。
function c29888389.rlevel(e,c)
	-- 获取当前卡的等级并限制在系统安全阈值内。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 效果发动时的费用处理，将此卡送去墓地作为费用。
function c29888389.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡因支付费用而送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选「遗式」仪式魔法卡。
function c29888389.filter(c)
	return c:IsSetCard(0x3a) and c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- 设置效果发动时的操作信息，确定将要从卡组检索的卡。
function c29888389.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在满足条件的「遗式」仪式魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c29888389.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理流程，选择并加入手牌。
function c29888389.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的「遗式」仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,c29888389.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
