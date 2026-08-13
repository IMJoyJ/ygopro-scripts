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
	-- ●1张以上：这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c34487429.desrepcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ●3张以上：魔法·陷阱卡的发动时，把自己场上1只表侧表示的「宝玉兽」怪兽送去墓地才能发动。那个发动无效并破坏。
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
	-- ●4张以上：1回合1次，可以发动。自己抽1张。
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
	-- ●5张：1回合1次，以自己的魔法与陷阱区域1张「宝玉兽」卡为对象才能发动。那张卡特殊召唤。
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
	-- ●2张以上：1回合1次，可以把对自己的战斗伤害变成一半。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(34487429,0))  --"伤害减半"
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e6:SetCondition(c34487429.rdcon)
	e6:SetOperation(c34487429.rdop)
	c:RegisterEffect(e6)
end
-- 过滤函数：筛选表侧表示且持有「宝玉兽」字段的卡。
function c34487429.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 「不会因效果被破坏」的发动条件：我方魔法与陷阱区域存在至少1张表侧表示的「宝玉兽」卡。
function c34487429.desrepcon(e)
	-- 判断我方魔法与陷阱区域是否存在至少1张表侧表示的「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c34487429.filter1,e:GetHandler():GetControler(),LOCATION_SZONE,0,1,nil)
end
-- 「魔法·陷阱发动无效并破坏」的发动条件：对方发动魔法·陷阱卡且该连锁可被无效，并且我方魔法与陷阱区域存在至少3张「宝玉兽」卡。
function c34487429.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定被连锁的效果是魔法·陷阱卡的发动，且该连锁可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 判定我方魔法与陷阱区域存在至少3张「宝玉兽」卡。
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_SZONE,0,3,nil,0x1034)
end
-- 过滤函数：筛选表侧表示、属于「宝玉兽」系列且可以作为代价送去墓地的怪兽。
function c34487429.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGraveAsCost()
end
-- 效果发动代价：从我方场上选择1只表侧表示且可作为代价的「宝玉兽」怪兽送去墓地。
function c34487429.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认我方场上是否存在满足代价条件的「宝玉兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34487429.filter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送选择提示，提示选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从我方场上选择1只符合条件的「宝玉兽」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c34487429.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽以代价形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动目标设定：登记无效并破坏的对象信息，若发动效果的卡可被破坏则追加破坏信息。
function c34487429.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记此次连锁的无效对象为发动的那张魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若那张卡可被破坏且仍与效果关联，则登记将其破坏的处理信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效该魔法·陷阱卡的发动，若成功且该卡仍关联，则将其破坏。
function c34487429.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定无效发动是否成功，且要被无效的卡仍与那个连锁相关。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效的魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 抽卡效果的发动条件：我方魔法与陷阱区域存在至少4张「宝玉兽」卡。
function c34487429.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断我方魔法与陷阱区域是否存在至少4张表侧表示的「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c34487429.filter1,tp,LOCATION_SZONE,0,4,nil)
end
-- 抽卡效果发动前的目标设定：确认我方可以抽卡，并登记抽卡对象玩家、数量与抽卡类别。
function c34487429.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方玩家是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次效果的抽卡玩家设为我方。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的抽卡数量设为1。
	Duel.SetTargetParam(1)
	-- 向系统登记本次操作类别为抽卡，目标玩家为我方，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从我方卡组抽1张卡。
function c34487429.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前登记的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 玩家p抽d张卡，原因视为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件：我方魔法与陷阱区域存在至少5张「宝玉兽」卡。
function c34487429.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断我方魔法与陷阱区域是否存在至少5张表侧表示的「宝玉兽」卡。
	return Duel.IsExistingMatchingCard(c34487429.filter1,tp,LOCATION_SZONE,0,5,nil)
end
-- 过滤函数：筛选表侧表示、属于「宝玉兽」系列且可以被特殊召唤的卡。
function c34487429.filter3(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标设定：检查指定对象是否是我方魔法与陷阱区域的表侧「宝玉兽」卡且可被特殊召唤；同时确认我方主要怪兽区有空位且存在合法对象。
function c34487429.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c34487429.filter3(chkc,e,tp) end
	-- 检查我方主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方魔法与陷阱区域是否存在至少1张符合条件的「宝玉兽」卡可作为对象。
		and Duel.IsExistingTarget(c34487429.filter3,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 给玩家发送选择提示，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从我方魔法与陷阱区域选择1张符合条件的「宝玉兽」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c34487429.filter3,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 登记本次操作类别为特殊召唤，对象为选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象卡以表侧攻击表示特殊召唤到我方场上。
function c34487429.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡特殊召唤到我方场上，表示形式为表侧攻击表示。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 伤害减半效果的适用条件：受到战斗伤害的是我方、本回合本卡效果尚未使用过，且我方魔法与陷阱区域存在至少2张「宝玉兽」卡。
function c34487429.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():GetFlagEffect(34487429)==0
		-- 判断我方魔法与陷阱区域是否存在至少2张表侧表示的「宝玉兽」卡。
		and Duel.IsExistingMatchingCard(c34487429.filter1,tp,LOCATION_SZONE,0,2,nil)
end
-- 效果处理：询问玩家是否发动伤害减半，若选择发动则将战斗伤害减半，并设置本回合已使用标记。
function c34487429.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问我方玩家是否发动伤害减半效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		-- 将我方受到的战斗伤害变为原伤害的一半（向下取整）。
		Duel.ChangeBattleDamage(tp,math.floor(ev/2))
		e:GetHandler():RegisterFlagEffect(34487429,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
