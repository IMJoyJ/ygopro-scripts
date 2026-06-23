--ラヴァル・ガンナー
-- 效果：
-- 这张卡召唤成功时，自己墓地有「熔岩炮击手」以外的名字带有「熔岩」的怪兽存在的场合，从自己卡组上面把最多5张卡送去墓地才能发动。这张卡的攻击力上升因为这个效果发动而送去墓地的名字带有「熔岩」的怪兽数量×200的数值。
function c11834972.initial_effect(c)
	-- 这张卡召唤成功时，自己墓地有「熔岩炮击手」以外的名字带有「熔岩」的怪兽存在的场合，从自己卡组上面把最多5张卡送去墓地才能发动。这张卡的攻击力上升因为这个效果发动而送去墓地的名字带有「熔岩」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11834972,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c11834972.condition)
	e1:SetCost(c11834972.cost)
	e1:SetOperation(c11834972.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查墓地是否存在名字带有「熔岩」且不是熔岩炮击手的怪兽
function c11834972.cfilter(c)
	return c:IsSetCard(0x39) and not c:IsCode(11834972)
end
-- 效果发动的条件判断函数
function c11834972.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张名字带有「熔岩」且不是熔岩炮击手的怪兽
	return Duel.IsExistingMatchingCard(c11834972.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 效果发动时的费用处理函数
function c11834972.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能作为费用把至少1张卡从卡组送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct={}
	for i=5,1,-1 do
		-- 检查玩家是否能作为费用把i张卡从卡组送去墓地
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,i) then
			table.insert(ct,i)
		end
	end
	if #ct==1 then
		-- 将玩家卡组最上面1张卡送去墓地作为费用
		Duel.DiscardDeck(tp,ct[1],REASON_COST)
	else
		-- 提示玩家选择将多少张卡送去墓地
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(11834972,1))  --"请选择送去墓地的数量"
		-- 让玩家宣言一个数字，表示要将多少张卡送去墓地
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		-- 将玩家卡组最上面ac张卡送去墓地作为费用
		Duel.DiscardDeck(tp,ac,REASON_COST)
	end
	-- 获取刚才进行的卡组送去墓地操作实际涉及的卡片组
	local g=Duel.GetOperatedGroup()
	e:SetLabel(g:FilterCount(Card.IsSetCard,nil,0x39)*200)
end
-- 效果发动时的处理函数
function c11834972.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡的攻击力上升因为这个效果发动而送去墓地的名字带有「熔岩」的怪兽数量×200的数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end
