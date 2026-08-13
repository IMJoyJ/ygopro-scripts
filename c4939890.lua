--シャドール・ヘッジホッグ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。从卡组把1张「影依」魔法·陷阱卡加入手卡。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依刺猬」以外的1只「影依」怪兽加入手卡。
function c4939890.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡反转的场合才能发动。从卡组把1张「影依」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4939890,0))  --"检索魔陷"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,4939890)
	e1:SetCost(c4939890.cost)
	e1:SetTarget(c4939890.target)
	e1:SetOperation(c4939890.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡被效果送去墓地的场合才能发动。从卡组把「影依刺猬」以外的1只「影依」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4939890,1))  --"检索怪兽"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,4939890)
	e2:SetCondition(c4939890.thcon)
	e2:SetCost(c4939890.cost)
	e2:SetTarget(c4939890.thtg)
	e2:SetOperation(c4939890.thop)
	c:RegisterEffect(e2)
	c4939890.shadoll_flip_effect=e1
end
-- 无实际代价的cost：效果发动时仅向对方玩家提示当前发动的效果描述，便于对方确认；check时返回true表示无需支付COST。
function c4939890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家(1-tp)发送HINT_OPSELECTED提示，内容为本效果描述，使对方知晓发动的是哪一条效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 定义①效果可检索的卡：必须是「影依」字段的魔法·陷阱卡，且能加入手卡。
function c4939890.filter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置①效果发动条件和操作信息：卡组存在满足filter的「影依」魔法·陷阱卡时可发动，并预告从卡组将1张卡加入手卡。
function c4939890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk=0）检查卡组是否存在至少1张满足filter的「影依」魔法·陷阱卡，作为能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c4939890.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：将1张卡从持有者tp的卡组加入手卡，供连锁检测与后续效果判断使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果：从卡组选择1张「影依」魔法·陷阱卡加入手卡，并让对手确认。
function c4939890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选卡提示，提示当前玩家tp选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足filter的「影依」魔法·陷阱卡，得到选中卡组g。
	local g=Duel.SelectMatchingCard(tp,c4939890.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡g以“效果”原因加入其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，证明检索行为。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果发动条件：该卡被效果（REASON_EFFECT）送去墓地时满足条件。
function c4939890.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义②效果可检索的卡：必须是「影依」字段的怪兽，且卡名不是「影依刺猬」，且能加入手卡。
function c4939890.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_MONSTER) and not c:IsCode(4939890) and c:IsAbleToHand()
end
-- 设置②效果发动条件和操作信息：卡组存在满足thfilter的怪兽时可发动，并预告从卡组将1张怪兽加入手卡。
function c4939890.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk=0）检查卡组是否存在至少1只满足thfilter的「影依」怪兽（除影依刺猬外），作为能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c4939890.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：将1张「影依」怪兽从持有者tp的卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：从卡组选择1只「影依刺猬」以外的「影依」怪兽加入手卡，并让对手确认。
function c4939890.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选卡提示，提示当前玩家tp选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1只满足thfilter的「影依」怪兽，得到选中卡组g。
	local g=Duel.SelectMatchingCard(tp,c4939890.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽g以“效果”原因加入其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽，证明检索行为。
		Duel.ConfirmCards(1-tp,g)
	end
end
