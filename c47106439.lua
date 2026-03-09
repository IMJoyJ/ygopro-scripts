--ヴィジョン・リチュア
-- 效果：
-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把1只「遗式」仪式怪兽加入手卡。
function c47106439.initial_effect(c)
	-- 效果原文内容：②：把这张卡从手卡丢弃才能发动。从卡组把1只「遗式」仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47106439,0))  --"仪式怪兽加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c47106439.cost)
	e1:SetTarget(c47106439.target)
	e1:SetOperation(c47106439.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(c47106439.rlevel)
	c:RegisterEffect(e2)
end
-- 规则层面操作：当仪式怪兽进行仪式召唤时，此卡可作为仪式召唤所需的等级值参与计算。
function c47106439.rlevel(e,c)
	-- 规则层面操作：获取此卡当前等级并确保不超过系统最大参数值。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 规则层面操作：支付将此卡从手卡丢弃作为发动代价。
function c47106439.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 规则层面操作：将此卡送入墓地作为支付代价的一部分。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 规则层面操作：定义用于检索的过滤条件，筛选「遗式」仪式怪兽且可加入手牌的卡片。
function c47106439.filter(c)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 规则层面操作：设置连锁处理信息，表明效果发动时会从卡组检索一张「遗式」仪式怪兽加入手牌。
function c47106439.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查在卡组中是否存在满足条件的「遗式」仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c47106439.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设定连锁处理信息中的目标为卡组中的一张「遗式」仪式怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行效果处理，选择并把符合条件的「遗式」仪式怪兽加入手牌，并向对方确认该卡。
function c47106439.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：从卡组中选择一张满足条件的「遗式」仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,c47106439.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡片送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：向对方玩家确认所选的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
