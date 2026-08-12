--魔法除去細菌兵器
-- 效果：
-- ①：把衍生物以外的自己场上的怪兽任意数量解放才能发动。对方从卡组选解放的怪兽数量的魔法卡送去墓地。
function c54591086.initial_effect(c)
	-- ①：把衍生物以外的自己场上的怪兽任意数量解放才能发动。对方从卡组选解放的怪兽数量的魔法卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c54591086.cost)
	e1:SetTarget(c54591086.target)
	e1:SetOperation(c54591086.activate)
	c:RegisterEffect(e1)
end
-- 设置Label为100，用于在target函数中确认是否通过cost流程进行发动
function c54591086.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：非衍生物的卡
function c54591086.rfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
-- 效果的发动准备与代价处理，选择并解放怪兽，并记录解放的数量
function c54591086.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1张可解放的非衍生物怪兽
		return Duel.CheckReleaseGroup(tp,c54591086.rfilter,1,nil)
	end
	-- 让玩家选择自己场上1到7张非衍生物怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,c54591086.rfilter,1,7,nil)
	e:SetLabel(rg:GetCount())
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- 过滤条件：可以送去墓地的魔法卡
function c54591086.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
-- 效果处理：对方从卡组选择与解放数量相同的魔法卡送去墓地
function c54591086.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 提示对方玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让对方玩家从自己的卡组中选择与解放数量相同的魔法卡
	local g=Duel.SelectMatchingCard(1-tp,c54591086.filter,1-tp,LOCATION_DECK,0,ct,ct,nil)
	if g:GetCount()>0 then
		-- 将对方选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
