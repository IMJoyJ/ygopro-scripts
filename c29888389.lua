--シャドウ・リチュア
-- 效果：
-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把1张「遗式」仪式魔法卡加入手卡。
function c29888389.initial_effect(c)
	-- ②：把这张卡从手卡丢弃才能发动。从卡组把1张「遗式」仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29888389,0))  --"仪式魔法卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c29888389.cost)
	e1:SetTarget(c29888389.target)
	e1:SetOperation(c29888389.operation)
	c:RegisterEffect(e1)
	-- ①：水属性仪式怪兽1只仪式召唤的场合，可以用这1张卡作为仪式召唤需要的数值的解放使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_LEVEL)
	e2:SetValue(c29888389.rlevel)
	c:RegisterEffect(e2)
end
-- 该函数是EFFECT_RITUAL_LEVEL的值函数，计算此卡作为仪式解放时可提供的等级：若仪式怪兽为水属性，返回(自身等级<<16)+对象等级，使此卡可当作自身等级与对象等级合计的解放值；否则只当作自身等级。
function c29888389.rlevel(e,c)
	-- 获取此卡的当前等级并做上限封顶保护，作为仪式解放时可提供的基础等级数值。
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return (lv<<16)+clv
	else return lv end
end
-- 定义效果②的代价函数：以从手卡丢弃此卡为发动代价；chk==0时检查此卡能否丢弃，能则实际丢弃送墓。
function c29888389.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以代价原因和丢弃原因从手卡送入墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：要求卡片具有「遗式」字段，类型为仪式魔法卡，并且可以被加入手卡。
function c29888389.filter(c)
	return c:IsSetCard(0x3a) and c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- 定义效果②的发动目标条件：若卡组存在符合过滤器的「遗式」仪式魔法卡，则发动合法；并登记本连锁为检索加入手卡的效果。
function c29888389.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段判断卡组中是否存在至少1张符合条件的「遗式」仪式魔法卡，如果没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29888389.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果的类别为加入手卡，预计将1张卡从卡组加入持有者手卡，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的处理操作：通过选择框从卡组挑选1张符合条件的「遗式」仪式魔法卡加入手卡，并让对方确认。
function c29888389.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 发出HINT_SELECTMSG提示，显示“请选择要加入手牌的卡”，用于搜索卡牌时的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行卡组检索：当前玩家从卡组中选取1张符合过滤条件的「遗式」仪式魔法卡。
	local g=Duel.SelectMatchingCard(tp,c29888389.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入持有者手卡，实现检索加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认，保证信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
