--氷結界の軍師
-- 效果：
-- ①：1回合1次，从手卡把1只「冰结界」怪兽送去墓地才能发动。自己抽1张。
function c50032342.initial_effect(c)
	-- 效果原文内容：①：1回合1次，从手卡把1只「冰结界」怪兽送去墓地才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50032342,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c50032342.cost)
	e1:SetTarget(c50032342.target)
	e1:SetOperation(c50032342.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：过滤函数，用于判断手牌或墓地中的卡片是否满足送去墓地的条件（包括是否为冰结界怪兽、是否能作为cost送入墓地等）
function c50032342.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 规则层面作用：处理效果发动时的费用支付，选择一张符合条件的卡送去墓地，并根据是否有特定效果进行替换除外或直接送入墓地的操作
function c50032342.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家手牌和墓地中是否存在至少一张满足条件的「冰结界」怪兽作为发动费用
	if chk==0 then return Duel.IsExistingMatchingCard(c50032342.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：让玩家从手牌或墓地中选择一张符合条件的卡作为效果发动的费用
	local g=Duel.SelectMatchingCard(tp,c50032342.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 规则层面作用：将选中的卡以除外形式移除（用于代替送去墓地的效果）
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 规则层面作用：将选中的卡送入墓地作为效果发动的费用
		Duel.SendtoGrave(tc,REASON_COST)
	end
end
-- 规则层面作用：设置效果的目标玩家和抽卡数量，准备执行抽卡操作
function c50032342.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查当前玩家是否可以进行抽卡操作
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面作用：设定当前连锁效果的目标玩家为使用该效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面作用：设定当前连锁效果的目标参数为1（表示抽1张卡）
	Duel.SetTargetParam(1)
	-- 规则层面作用：设置当前连锁效果的操作信息，表明将执行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面作用：执行效果的最终处理，根据连锁信息获取目标玩家和抽卡数量并执行抽卡
function c50032342.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：从当前连锁中获取目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：让指定玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
