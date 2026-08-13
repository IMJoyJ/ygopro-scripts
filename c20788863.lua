--サラマングレイト・ギフト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡丢弃1只「转生炎兽」怪兽才能发动。从卡组把1只「转生炎兽」怪兽送去墓地。那之后，自己从卡组抽1张。
-- ②：用和自身同名的怪兽为素材作连接召唤的「转生炎兽」连接怪兽在自己场上存在的场合，从手卡丢弃1只「转生炎兽」怪兽才能发动。自己从卡组抽2张。
function c20788863.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应①效果原文：从手卡丢弃1只「转生炎兽」怪兽才能发动。从卡组把1只「转生炎兽」怪兽送去墓地。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20788863,0))  --"堆墓并抽1张卡"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,20788863)
	e2:SetCost(c20788863.cost)
	e2:SetTarget(c20788863.drtg1)
	e2:SetOperation(c20788863.drop1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e2)
	-- 对应②效果原文：用和自身同名的怪兽为素材作连接召唤的「转生炎兽」连接怪兽在自己场上存在的场合，从手卡丢弃1只「转生炎兽」怪兽才能发动。自己从卡组抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20788863,1))  --"抽2张卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,20788863)
	e3:SetCondition(c20788863.drcon)
	e3:SetCost(c20788863.cost)
	e3:SetTarget(c20788863.drtg2)
	e3:SetOperation(c20788863.drop2)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e3)
	if not c20788863.global_check then
		c20788863.global_check=true
		-- 对应②效果中的条件部分：用和自身同名的怪兽为素材作连接召唤的「转生炎兽」连接怪兽在自己场上存在的场合。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c20788863.valcheck)
		-- 将全局素材检查效果注册到场上，用于在连接召唤时检测素材中是否存在与连接怪兽同名的「转生炎兽」怪兽。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 素材检查回调：若本次连接召唤的素材中存在与召唤出的连接怪兽同卡名的卡，则为该连接怪兽注册20788863标志，标记其满足②效果所需条件。
function c20788863.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkCode,1,nil,c:GetCode()) then
		c:RegisterFlagEffect(20788863,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 筛选手卡中可作为代价丢弃的「转生炎兽」怪兽：属于0x119系列、是怪兽且可以被丢弃。
function c20788863.cfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ①②效果共用的代价处理：发动前检查手卡是否有可丢弃的「转生炎兽」怪兽；发动时从手卡丢弃1张满足条件的「转生炎兽」怪兽作为代价。
function c20788863.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：手卡中是否存在至少1张可丢弃的「转生炎兽」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20788863.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手卡选择并丢弃1张「转生炎兽」怪兽，丢弃原因为代价并视为丢弃。
	Duel.DiscardHand(tp,c20788863.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选卡组中可送去墓地的「转生炎兽」怪兽：属于0x119系列、是怪兽且可以送去墓地，用于①效果的堆墓。
function c20788863.filter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件检测：确认自己可以抽1张卡，并且卡组中存在至少1张能被送去墓地的「转生炎兽」怪兽，满足条件才可发动。
function c20788863.drtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡，排除“不能抽卡”等限制，作为①效果的发动前提之一。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查卡组中是否存在至少1张可送去墓地的「转生炎兽」怪兽，保证①效果堆墓部分能够处理。
		and Duel.IsExistingMatchingCard(c20788863.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁包含把卡组中的1张「转生炎兽」怪兽送去墓地的效果，目标为卡组（不取对象，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本连锁包含抽1张卡的效果，抽卡玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：从卡组选择1张「转生炎兽」怪兽送去墓地；若成功送墓且该卡在墓地中，则洗切卡组，中断效果后让自己抽1张卡。
function c20788863.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的「转生炎兽」怪兽，作为送去墓地的对象。
	local g=Duel.SelectMatchingCard(tp,c20788863.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断选择组非空、送墓操作实际成功且被送去墓地的卡确实位于墓地中，只有满足这些条件才执行后续抽卡。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 洗切卡组，因为从卡组取出了卡片，需要重置卡组顺序。
		Duel.ShuffleDeck(tp)
		-- 中断当前效果，让“送去墓地”和“抽卡”作为不同时处理，以符合“那之后”的时点关系。
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡，对应①效果后半段的“那之后，自己从卡组抽1张”。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 筛选满足②效果条件的连接怪兽：表侧表示、属于「转生炎兽」系列、通过连接召唤出场、且带有20788863标志（即用同名怪兽为素材连接召唤）。
function c20788863.lfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x119) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(20788863)~=0
end
-- ②效果的发动条件：自己场上存在至少1只用同名怪兽为素材连接召唤出来的「转生炎兽」连接怪兽。
function c20788863.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主怪兽区是否存在至少1只满足lfilter条件的「转生炎兽」连接怪兽。
	return Duel.IsExistingMatchingCard(c20788863.lfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标设定：确认自己可以抽2张卡，然后将目标玩家设为自己、抽卡参数设为2，并设置操作信息。
function c20788863.drtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己是否可以抽2张卡，若不能抽则②效果不可发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的object玩家设为自己，表示本次抽卡的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的object参数设为2，表示要抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置操作信息：本连锁包含抽2张卡的效果，目标玩家为自己，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果处理：从连锁信息中取出保存的目标玩家和抽卡数量，让该玩家抽对应数量的卡。
function c20788863.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设定的目标玩家p和抽卡数量d，供实际抽卡使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，即自己抽2张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
