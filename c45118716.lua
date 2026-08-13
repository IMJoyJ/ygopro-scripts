--マジック・リサイクラー
-- 效果：
-- 对方怪兽的攻击宣言时把墓地的这张卡从游戏中除外，选择自己墓地1张魔法卡才能发动。自己卡组最上面的卡送去墓地，选择的卡回到卡组最下面。
function c45118716.initial_effect(c)
	-- 对方怪兽的攻击宣言时把墓地的这张卡从游戏中除外，选择自己墓地1张魔法卡才能发动。自己卡组最上面的卡送去墓地，选择的卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45118716,0))  --"魔法回收"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c45118716.condition)
	-- 设置效果的发动代价：把墓地中的这张卡除外（aux.bfgcost）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c45118716.target)
	e1:SetOperation(c45118716.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：对方怪兽攻击宣言时（ep~=tp，即攻击玩家不是自己）才可发动。
function c45118716.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 目标过滤：选择自己墓地1张魔法卡且可以被送回卡组的卡作为对象。
function c45118716.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 效果目标的发动处理：连锁检查对象合法性（chkc），之后在chk==0时确认发动可行，并选择自己墓地1张符合条件的魔法卡作为对象。
function c45118716.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45118716.filter(chkc) end
	-- 检查发动合法性之一：己方能够把卡组最上面1张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查发动合法性之二：自己墓地存在至少1张符合条件的魔法卡可以作为效果对象。
		and Duel.IsExistingTarget(c45118716.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地的合法魔法卡中选择1张，并设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c45118716.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本次效果包含将卡返回卡组的处理，对象为所选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：先将己方卡组最上面1张卡送去墓地，若成功且对象卡仍与效果关联，则把对象卡送回持有者卡组最下面。
function c45118716.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 执行卡组丢弃并判断：卡组最上面1张卡成功送去墓地，且对象卡仍与效果关联。
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者卡组最下面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
