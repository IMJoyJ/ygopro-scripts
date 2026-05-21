--モンスター回収
-- 效果：
-- 选择原本持有者是自己的自己场上1只怪兽才能发动。选择的怪兽和自己手卡全部加入卡组洗切。那之后，从卡组抽出原本的手卡数量的卡。原本持有者是对方的卡在自己手卡的场合，这张卡不能发动。
function c93108433.initial_effect(c)
	-- 选择原本持有者是自己的自己场上1只怪兽才能发动。选择的怪兽和自己手卡全部加入卡组洗切。那之后，从卡组抽出原本的手卡数量的卡。原本持有者是对方的卡在自己手卡的场合，这张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c93108433.target)
	e1:SetOperation(c93108433.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：可以回到卡组且原本持有者是自己的卡
function c93108433.mfilter(c,tp)
	return c:IsAbleToDeck() and tp==c:GetOwner()
end
-- 过滤条件：原本持有者是对方的卡
function c93108433.hfilter(c,tp)
	return tp~=c:GetOwner()
end
-- 发动条件与对象选择的判定：检查是否满足发动条件（能抽卡、手牌数大于0、场上有满足条件的怪兽、手牌中没有原本持有者是对方的卡）
function c93108433.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c93108433.mfilter(chkc,tp) end
	-- 检查自身是否可以抽卡，且手牌数量大于0
	if chk==0 then return Duel.IsPlayerCanDraw(tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查自己场上是否存在至少1只可以作为效果对象、且原本持有者是自己的怪兽
		and Duel.IsExistingTarget(c93108433.mfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp)
		-- 检查自己手牌中是否不存在原本持有者是对方的卡
		and not Duel.IsExistingMatchingCard(c93108433.hfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上1只原本持有者是自己的怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c93108433.mfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取自己手牌的所有卡
	local g2=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	g1:Merge(g2)
	-- 设置操作信息：将选中的怪兽和手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
	-- 设置操作信息：从卡组抽等同于手牌数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g2:GetCount())
end
-- 效果处理：将选择的怪兽和手牌全部加入卡组洗切，之后从卡组抽出原本手牌数量的卡
function c93108433.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取当前自己的手牌
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=g:GetCount()
	if tc:IsRelateToEffect(e) and ct>0 then
		g:AddCard(tc)
		-- 将包含选择的怪兽和手牌在内的卡片组送回持有者的卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		if ct>0 then
			-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
			Duel.BreakEffect()
			-- 从卡组抽出原本手牌数量的卡
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
