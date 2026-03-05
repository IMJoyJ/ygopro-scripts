--ウィッチクラフト・スクロール
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：1回合1次，自己的魔法师族怪兽战斗破坏怪兽时才能发动。自己从卡组抽1张。
-- ②：自己场上的「魔女术」怪兽为让效果发动而把手卡丢弃的场合，可以作为代替把这张卡送去墓地。
-- ③：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
function c19673561.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己的魔法师族怪兽战斗破坏怪兽时才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19673561,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c19673561.drcon)
	e1:SetTarget(c19673561.drtg)
	e1:SetOperation(c19673561.drop)
	c:RegisterEffect(e1)
	-- ③：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19673561,0))  --"抽卡"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,19673561)
	e2:SetCondition(c19673561.setcon)
	e2:SetTarget(c19673561.settg)
	e2:SetOperation(c19673561.setop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(83289866)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,19673561)
	c:RegisterEffect(e3)
end
-- 判断触发效果的条件：战斗破坏的怪兽是否与自己控制的魔法师族怪兽相关且处于战斗状态。
function c19673561.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsRace(RACE_SPELLCASTER) and rc:IsControler(tp)
end
-- 设置效果的目标玩家和参数，准备执行抽卡效果。
function c19673561.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡，防止在无法抽卡的状态下发动效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1。
	Duel.SetTargetParam(1)
	-- 设置效果操作信息，表示将执行抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，从卡组抽取指定数量的卡。
function c19673561.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数，用于执行抽卡操作。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，从卡组抽取指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数，用于判断场上是否存在「魔女术」怪兽。
function c19673561.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 判断效果发动条件：当前回合玩家为效果使用者，并且场上有「魔女术」怪兽。
function c19673561.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果使用者。
	return Duel.GetTurnPlayer()==tp
		-- 判断场上是否存在「魔女术」怪兽。
		and Duel.IsExistingMatchingCard(c19673561.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果的目标，准备执行将卡移回魔法与陷阱区域的操作。
function c19673561.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置效果操作信息，表示将卡从墓地移回魔法与陷阱区域。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行将卡移回魔法与陷阱区域的操作。
function c19673561.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查目标玩家的魔法与陷阱区域是否有空位，若无则不执行效果。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡移动到目标玩家的魔法与陷阱区域并设置为表侧表示。
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
