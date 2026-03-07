--虹の古代都市－レインボー・ルイン
-- 效果：
-- ①：得到自己的魔法与陷阱区域的「宝玉兽」卡数量的以下效果。
-- ●1张以上：这张卡不会被效果破坏。
-- ●2张以上：1回合1次，可以把对自己的战斗伤害变成一半。
-- ●3张以上：魔法·陷阱卡的发动时，把自己场上1只表侧表示的「宝玉兽」怪兽送去墓地才能发动。那个发动无效并破坏。
-- ●4张以上：1回合1次，可以发动。自己抽1张。
-- ●5张：1回合1次，以自己的魔法与陷阱区域1张「宝玉兽」卡为对象才能发动。那张卡特殊召唤。
function c34487429.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：●1张以上：这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c34487429.desrepcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 效果原文：●3张以上：魔法·陷阱卡的发动时，把自己场上1只表侧表示的「宝玉兽」怪兽送去墓地才能发动。那个发动无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34487429,1))  --"魔法·陷阱发动无效并破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c34487429.discon)
	e3:SetCost(c34487429.discost)
	e3:SetTarget(c34487429.distg)
	e3:SetOperation(c34487429.disop)
	c:RegisterEffect(e3)
	-- 效果原文：●4张以上：1回合1次，可以发动。自己抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34487429,2))  --"从自己卡组抽1张卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c34487429.drcon)
	e4:SetTarget(c34487429.drtg)
	e4:SetOperation(c34487429.drop)
	c:RegisterEffect(e4)
	-- 效果原文：●5张：1回合1次，以自己的魔法与陷阱区域1张「宝玉兽」卡为对象才能发动。那张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(34487429,3))  --"魔法与陷阱卡区域的「宝玉兽」卡特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c34487429.spcon)
	e5:SetTarget(c34487429.sptg)
	e5:SetOperation(c34487429.spop)
	c:RegisterEffect(e5)
	-- 效果原文：●2张以上：1回合1次，可以把对自己的战斗伤害变成一半。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(34487429,0))  --"伤害减半"
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e6:SetCondition(c34487429.rdcon)
	e6:SetOperation(c34487429.rdop)
	c:RegisterEffect(e6)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「宝玉兽」卡。
function c34487429.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 判断是否满足效果条件：场上存在至少1张「宝玉兽」卡。
function c34487429.desrepcon(e)
	-- 判断是否满足效果条件：场上存在至少1张「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c34487429.filter1,e:GetHandler():GetControler(),LOCATION_SZONE,0,1,nil)
end
-- 判断是否满足效果条件：对方发动的是魔法或陷阱卡，并且该连锁可以被无效，且自己场上存在至少3张「宝玉兽」卡。
function c34487429.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果条件：对方发动的是魔法或陷阱卡，并且该连锁可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 判断是否满足效果条件：自己场上存在至少3张「宝玉兽」卡。
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_SZONE,0,3,nil,0x1034)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「宝玉兽」怪兽且能送去墓地。
function c34487429.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGraveAsCost()
end
-- 效果处理：选择场上1只表侧表示的「宝玉兽」怪兽送去墓地作为发动代价。
function c34487429.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上存在至少1只表侧表示的「宝玉兽」怪兽且能送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c34487429.filter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只表侧表示的「宝玉兽」怪兽送去墓地。
	local g=Duel.SelectMatchingCard(tp,c34487429.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的卡送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理时的操作信息：使发动无效并破坏。
function c34487429.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的操作信息：使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理时的操作信息：破坏发动的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使连锁发动无效并破坏发动的卡。
function c34487429.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果处理条件：连锁发动可以被无效且发动的卡存在。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断是否满足效果条件：场上存在至少4张「宝玉兽」卡。
function c34487429.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果条件：场上存在至少4张「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c34487429.filter1,tp,LOCATION_SZONE,0,4,nil)
end
-- 设置效果处理时的操作信息：自己抽1张卡。
function c34487429.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1。
	Duel.SetTargetParam(1)
	-- 设置效果处理时的操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：自己抽1张卡。
function c34487429.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断是否满足效果条件：场上存在至少5张「宝玉兽」卡。
function c34487429.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果条件：场上存在至少5张「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c34487429.filter1,tp,LOCATION_SZONE,0,5,nil)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「宝玉兽」卡且能特殊召唤。
function c34487429.filter3(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的操作信息：选择目标并特殊召唤。
function c34487429.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c34487429.filter3(chkc,e,tp) end
	-- 判断是否满足发动条件：自己场上存在至少1张「宝玉兽」卡且能特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：自己场上存在至少1张「宝玉兽」卡且能特殊召唤。
		and Duel.IsExistingTarget(c34487429.filter3,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择场上1张「宝玉兽」卡作为特殊召唤的目标。
	local g=Duel.SelectTarget(tp,c34487429.filter3,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息：特殊召唤目标卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的卡特殊召唤。
function c34487429.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足效果条件：自己受到战斗伤害且场上存在至少2张「宝玉兽」卡。
function c34487429.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffect(34487429)==0
		-- 判断是否满足效果条件：场上存在至少2张「宝玉兽」卡。
		and Duel.IsExistingMatchingCard(c34487429.filter1,tp,LOCATION_SZONE,0,2,nil)
end
-- 效果处理：选择是否将受到的战斗伤害减半。
function c34487429.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否选择发动效果：选择是否将受到的战斗伤害减半。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		-- 将玩家受到的战斗伤害减半。
		Duel.ChangeBattleDamage(tp,math.floor(ev/2))
		e:GetHandler():RegisterFlagEffect(34487429,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
