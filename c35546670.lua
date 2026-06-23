--星遺物が刻む傷痕
-- 效果：
-- ①：场上的「机界骑士」怪兽的攻击力·守备力上升300。
-- ②：1回合1次，从手卡丢弃1只「机界骑士」怪兽或者1张「星遗物」卡才能发动。自己从卡组抽1张。
-- ③：从自己墓地以及自己场上的表侧表示怪兽之中把「机界骑士」怪兽8种类各1只除外才能发动。对方的手卡·额外卡组的卡全部送去墓地。
function c35546670.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「机界骑士」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	-- 筛选场上的「机界骑士」怪兽作为效果对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10c))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，从手卡丢弃1只「机界骑士」怪兽或者1张「星遗物」卡才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35546670,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c35546670.drcost)
	e4:SetTarget(c35546670.drtg)
	e4:SetOperation(c35546670.drop)
	c:RegisterEffect(e4)
	-- ③：从自己墓地以及自己场上的表侧表示怪兽之中把「机界骑士」怪兽8种类各1只除外才能发动。对方的手卡·额外卡组的卡全部送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(35546670,1))  --"全部送去墓地"
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCost(c35546670.tgcost)
	e5:SetTarget(c35546670.tgtg)
	e5:SetOperation(c35546670.tgop)
	c:RegisterEffect(e5)
end
-- 用于判断手卡中是否满足丢弃条件的过滤函数，包括「机界骑士」怪兽或「星遗物」卡
function c35546670.costfilter1(c)
	return ((c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe)) and c:IsDiscardable()
end
-- 检查手卡是否存在满足条件的卡并将其丢弃
function c35546670.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35546670.costfilter1,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方提示本效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 从手卡丢弃1张满足条件的卡
	Duel.DiscardHand(tp,c35546670.costfilter1,1,1,REASON_DISCARD+REASON_COST)
end
-- 设置抽卡效果的目标参数
function c35546670.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标数量
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c35546670.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 用于判断除外条件的过滤函数，必须是「机界骑士」怪兽且在场上或墓地
function c35546670.costfilter2(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
-- 检查场上及墓地是否存在满足条件的卡并选择8种不同种类的卡除外
function c35546670.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上及墓地所有满足条件的卡
	local g=Duel.GetMatchingGroup(c35546670.costfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=8 end
	-- 向对方提示本效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置额外检查条件为卡名各不相同
	aux.GCheckAdditional=aux.dncheck
	-- 选择8种不同种类的卡
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,8,8)
	-- 取消额外检查条件
	aux.GCheckAdditional=nil
	-- 将选中的卡除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 设置送去墓地效果的目标参数
function c35546670.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡和额外卡组是否存在可送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,1,nil) end
	-- 获取对方手卡和额外卡组所有可送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,nil)
	-- 设置送去墓地效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 执行送去墓地效果
function c35546670.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡和额外卡组所有可送去墓地的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,nil)
	-- 将卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
