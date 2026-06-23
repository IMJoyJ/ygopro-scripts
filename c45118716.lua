--マジック・リサイクラー
-- 效果：
-- 对方怪兽的攻击宣言时把墓地的这张卡从游戏中除外，选择自己墓地1张魔法卡才能发动。自己卡组最上面的卡送去墓地，选择的卡回到卡组最下面。
function c45118716.initial_effect(c)
	-- 对方怪兽的攻击宣言时把墓地的这张卡从游戏中除外，选择自己墓地1张魔法卡才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45118716,0))  --"魔法回收"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c45118716.condition)
	-- 将此卡从游戏中除外作为费用
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45118716.target)
	e1:SetOperation(c45118716.operation)
	c:RegisterEffect(e1)
end
-- 攻击方不是发动玩家
function c45118716.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤满足条件的魔法卡
function c45118716.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 选择目标：自己墓地1张魔法卡
function c45118716.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45118716.filter(chkc) end
	-- 检查自己是否能从卡组最上面送1张卡到墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己墓地是否存在满足条件的魔法卡
		and Duel.IsExistingTarget(c45118716.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡作为目标
	local g=Duel.SelectTarget(tp,c45118716.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标卡送回卡组底端
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：自己卡组最上面的卡送去墓地，选择的卡回到卡组最下面
function c45118716.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 将自己卡组最上面的卡送去墓地且目标卡存在于连锁中
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 将目标卡送回卡组底端
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
