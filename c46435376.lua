--インフェルニティ・セイジ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己手卡全部丢弃。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「永火」怪兽送去墓地。这个效果在自己手卡是0张的场合才能发动和处理。
function c46435376.initial_effect(c)
	-- ①：自己主要阶段才能发动。自己手卡全部丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46435376,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,46435376)
	e1:SetTarget(c46435376.hdtg)
	e1:SetOperation(c46435376.hdop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把1只「永火」怪兽送去墓地。这个效果在自己手卡是0张的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46435376,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,46435377)
	e2:SetCondition(c46435376.tgcon)
	e2:SetTarget(c46435376.tgtg)
	e2:SetOperation(c46435376.tgop)
	c:RegisterEffect(e2)
end
-- 检查是否满足效果①的发动条件，即自己手牌数量大于0
function c46435376.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①的发动条件，即自己手牌数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 获取自己手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 设置连锁操作信息，表示将要处理自己手牌全部丢弃的效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,g:GetCount())
end
-- 效果①的处理函数，将自己手牌全部送去墓地
function c46435376.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手牌组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 将手牌组全部以效果和丢弃原因送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
end
-- 效果②的发动条件判断函数，检查自己手牌是否为0张
function c46435376.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手牌数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 筛选卡组中满足「永火」种族、怪兽类型且能被送去墓地的卡片
function c46435376.tgfilter(c)
	return c:IsSetCard(0xb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果②的目标选择函数，检查卡组中是否存在符合条件的「永火」怪兽
function c46435376.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合条件的「永火」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46435376.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理从卡组送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数，在满足条件时从卡组选择一只「永火」怪兽送去墓地
function c46435376.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手牌数量是否为0，以确认是否可以发动效果②
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择一张符合条件的「永火」怪兽
		local g=Duel.SelectMatchingCard(tp,c46435376.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「永火」怪兽以效果原因送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
