--妖仙獣の風祀り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「妖仙兽」怪兽卡3种类以上存在的场合才能发动。自己场上的「妖仙兽」怪兽卡全部回到持有者手卡。那之后，自己可以直到手卡变成5张为止从卡组抽卡。
function c54880296.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「妖仙兽」怪兽卡3种类以上存在的场合才能发动。自己场上的「妖仙兽」怪兽卡全部回到持有者手卡。那之后，自己可以直到手卡变成5张为止从卡组抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,54880296+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c54880296.condition)
	e1:SetTarget(c54880296.target)
	e1:SetOperation(c54880296.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「妖仙兽」怪兽卡（包含作为魔法·陷阱卡在场上存在的怪兽卡）
function c54880296.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 发动条件：自己场上有「妖仙兽」怪兽卡3种类以上存在
function c54880296.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「妖仙兽」怪兽卡
	local g=Duel.GetMatchingGroup(c54880296.cfilter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 过滤条件：自己场上表侧表示且能回到手牌的「妖仙兽」怪兽卡
function c54880296.filter(c)
	return c54880296.cfilter(c) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与处理：检查是否存在可回手牌的卡，并注册回手牌的操作信息
function c54880296.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张可以回到手牌的「妖仙兽」怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54880296.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 获取自己场上所有可以回到手牌的「妖仙兽」怪兽卡组
	local g=Duel.GetMatchingGroup(c54880296.filter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置操作信息：将这些卡全部送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将自己场上的「妖仙兽」怪兽卡全部回到手牌，之后可抽卡直到手牌变成5张
function c54880296.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有可以回到手牌的「妖仙兽」怪兽卡
	local sg=Duel.GetMatchingGroup(c54880296.filter,tp,LOCATION_ONFIELD,0,nil)
	-- 将这些卡全部回到持有者手牌，若有卡成功回到手牌则继续处理
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		-- 计算直到手牌变成5张为止需要抽卡的数量
		local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 如果需要抽卡（手牌少于5张）且玩家当前可以抽卡
		if ct>0 and Duel.IsPlayerCanDraw(tp,ct)
			-- 询问玩家是否选择进行抽卡
			and Duel.SelectYesNo(tp,aux.Stringid(54880296,0)) then  --"是否抽卡？"
			-- 中断当前效果处理，使后续的抽卡处理与回手牌不视为同时进行
			Duel.BreakEffect()
			-- 玩家从卡组抽卡直到手牌变成5张
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end
