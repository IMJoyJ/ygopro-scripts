--異次元からの埋葬
-- 效果：
-- ①：从除外的自己以及对方的怪兽之中以合计最多3只为对象才能发动。那些怪兽回到墓地。
function c48976825.initial_effect(c)
	-- ①：从除外的自己以及对方的怪兽之中以合计最多3只为对象才能发动。那些怪兽回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48976825.target)
	e1:SetOperation(c48976825.activate)
	c:RegisterEffect(e1)
end
-- 过滤除外区表侧表示的怪兽卡
function c48976825.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果发动的目标选择与检测函数
function c48976825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c48976825.filter(chkc) end
	-- 发动检测：检查双方除外区是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c48976825.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 设置玩家选择卡片时的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48976825,0))  --"请选择要回到墓地的卡"
	-- 选择1到3只除外区的表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c48976825.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
	-- 设置操作信息：将选中的对象卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理的Operation函数，使选中的卡片回到墓地
function c48976825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将目标怪兽送去墓地（作为回到墓地处理）
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
