--異次元からの埋葬
-- 效果：
-- ①：从除外的自己以及对方的怪兽之中以合计最多3只为对象才能发动。那些怪兽回到墓地。
function c48976825.initial_effect(c)
	-- 效果原文内容
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48976825.target)
	e1:SetOperation(c48976825.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组
function c48976825.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果作用
function c48976825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c48976825.filter(chkc) end
	-- 判断是否满足发动条件
	if chk==0 then return Duel.IsExistingTarget(c48976825.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 向玩家提示选择卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48976825,0))  --"请选择要回到墓地的卡"
	-- 选择最多3只除外怪兽作为对象
	local g=Duel.SelectTarget(tp,c48976825.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
	-- 设置连锁操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果作用
function c48976825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将对象卡送入墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
