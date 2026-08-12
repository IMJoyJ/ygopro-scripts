--ミュートリアル・ミスト
-- 效果：
-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡不会成为对方的魔法卡的效果的对象。
-- ②：对方把陷阱卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。自己从卡组抽2张。
-- ③：这张卡被对方破坏的场合，以除外的1只自己的「秘异三变」怪兽为对象才能发动。那只怪兽加入手卡。
function c61089209.initial_effect(c)
	-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c61089209.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡不会成为对方的魔法卡的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c61089209.ctval)
	c:RegisterEffect(e2)
	-- ②：对方把陷阱卡的效果发动时，从自己的手卡·场上把1张卡除外才能发动。自己从卡组抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,61089209)
	e3:SetCondition(c61089209.drcon)
	e3:SetCost(c61089209.drcost)
	e3:SetTarget(c61089209.drtg)
	e3:SetOperation(c61089209.drop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合，以除外的1只自己的「秘异三变」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,61089210)
	e4:SetCondition(c61089209.thcon)
	e4:SetTarget(c61089209.thtg)
	e4:SetOperation(c61089209.thop)
	c:RegisterEffect(e4)
end
-- 特殊召唤限制的过滤函数，限制只能通过「秘异三变」卡的效果特殊召唤
function c61089209.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x157)
end
-- 判定是否为对方的魔法卡效果对象的过滤函数
function c61089209.ctval(e,re,rp)
	-- 判定效果发动者为对方且效果卡片类型为魔法卡
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_SPELL)
end
-- 抽卡效果的发动条件：此卡未在战斗中被破坏，且对方发动了陷阱卡的效果
function c61089209.drcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and re:IsActiveType(TYPE_TRAP)
end
-- 抽卡效果的Cost：从自己的手卡或场上将1张卡除外
function c61089209.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在至少1张可以作为Cost除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择手卡或场上的1张卡作为Cost
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡表侧表示除外作为发动Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 抽卡效果的Target：检查玩家是否能抽2张卡，并设置抽卡操作信息
function c61089209.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 抽卡效果的Operation：获取目标玩家和参数，执行抽卡
function c61089209.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 回收效果的发动条件：此卡被对方破坏，且破坏前由自己控制
function c61089209.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤函数：检索除外状态的、表侧表示的「秘异三变」怪兽，且该怪兽可以加入手卡
function c61089209.thtgfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsFaceup()
end
-- 回收效果的Target：选择除外的1只「秘异三变」怪兽作为对象，并设置回收操作信息
function c61089209.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c61089209.thtgfilter(chkc) end
	-- 检查除外区是否存在至少1只满足条件的「秘异三变」怪兽
	if chk==0 then return Duel.IsExistingTarget(c61089209.thtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择除外区的1只满足条件的「秘异三变」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61089209.thtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的Operation：将选中的对象怪兽加入手卡
function c61089209.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选中的第一个效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
