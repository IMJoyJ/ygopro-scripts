--エンペラー・ストゥム
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，自己对怪兽的上级召唤成功时，双方玩家可以选择各自墓地存在的1张卡回到卡组最上面。
function c21672573.initial_effect(c)
	-- 创建一个诱发选发效果，当自己上级召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21672573,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c21672573.tdcon1)
	e1:SetTarget(c21672573.tdtg)
	e1:SetOperation(c21672573.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	e2:SetCondition(c21672573.tdcon2)
	c:RegisterEffect(e2)
end
-- 效果条件：上级召唤的怪兽不是自己，且是自己召唤的
function c21672573.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()~=e:GetHandler() and ep==tp
		and eg:GetFirst():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果条件：召唤的怪兽有素材，且是自己召唤的
function c21672573.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetMaterialCount()~=0 and ep==tp
end
-- 效果处理：选择自己墓地1张卡返回卡组最上面，对方可选择是否也选择1张卡返回卡组最上面
function c21672573.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张卡作为返回卡组的对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 检查对方墓地是否存在可返回卡组的卡
	if Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
		-- 询问对方是否选择墓地1张卡返回卡组最上面
		and Duel.SelectYesNo(1-tp,aux.Stringid(21672573,1)) then  --"是否要选择墓地一张卡回到卡组最上面？"
		-- 提示对方玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择对方墓地1张卡作为返回卡组的对象
		local g2=Duel.SelectTarget(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_GRAVE,0,1,1,nil)
		g1:Merge(g2)
	end
	-- 设置效果处理信息，指定返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- 效果处理：将选定的卡返回卡组最上面
function c21672573.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取连锁中选定的卡，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将卡返回卡组最上面，原因来自效果
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
