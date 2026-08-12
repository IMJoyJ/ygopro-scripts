--A・O・J サイクルリーダー
-- 效果：
-- 把这张卡从手卡丢弃去墓地发动。选择对方墓地存在的最多2只光属性怪兽从游戏中除外。这个效果在对方回合也能发动。
function c8233522.initial_effect(c)
	-- 把这张卡从手卡丢弃去墓地发动。选择对方墓地存在的最多2只光属性怪兽从游戏中除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8233522,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c8233522.cost)
	e1:SetTarget(c8233522.target)
	e1:SetOperation(c8233522.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理函数：检查并执行将此卡从手卡丢弃去墓地
function c8233522.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsDiscardable() end
	-- 将此卡作为发动代价丢弃去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：光属性且可以被除外的怪兽
function c8233522.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemove()
end
-- 效果的目标选择函数：进行取对象判定，选择对方墓地最多2只光属性怪兽，并设置除外的操作信息
function c8233522.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c8233522.filter(chkc) end
	-- 在效果发动时，检查对方墓地是否存在至少1只满足条件的光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c8233522.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 在界面上提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1到2只满足条件的光属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c8233522.filter,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置连锁的操作信息：除外对方墓地的目标卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理函数：将选中的对象怪兽除外
function c8233522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
