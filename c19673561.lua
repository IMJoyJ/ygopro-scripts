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
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。③：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
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
	-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。②：自己场上的「魔女术」怪兽为让效果发动而把手卡丢弃的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(83289866)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,19673561)
	c:RegisterEffect(e3)
end
-- ①的发动条件判定：本次战斗破坏怪兽的己方怪兽必须与对方怪兽进行过战斗、表侧表示、属于魔法师族且由自己控制。
function c19673561.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsRace(RACE_SPELLCASTER) and rc:IsControler(tp)
end
-- ①的发动时处理：检查能否抽卡，将抽卡对象玩家设为自己、抽卡数设为1，并声明本次为抽卡效果。
function c19673561.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：当前玩家能否以效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的对象玩家设定为当前玩家（即自己）。
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设定为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：当前连锁的抽卡处理目标为自己、抽卡1张、不取对象，使相关卡能正确识别该抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①的效果处理函数：执行抽卡，让自己抽1张卡。
function c19673561.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家和抽卡参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽取d张卡，实际执行①的抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤函数：用于判断怪兽是否为表侧表示且属于「魔女术」系列。
function c19673561.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- ③的发动条件：当前是自己回合的结束阶段，且自己场上有表侧表示的「魔女术」怪兽。
function c19673561.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是自己，即只在自己结束阶段才可能发动。
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在至少1只表侧表示的「魔女术」怪兽。
		and Duel.IsExistingMatchingCard(c19673561.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③的发动时处理：确认自己魔陷区有空位，并将这张卡作为从墓地离开的对象登记到操作信息中。
function c19673561.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己魔法与陷阱区域必须存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置操作信息：把墓地里的这张卡作为涉及离开墓地的对象，供后续移动处理和锁定类效果判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③的效果处理：若魔陷区还有空位且这张卡仍在墓地并能与效果关联，则将其表侧表示放置到自己的魔法与陷阱区域。
function c19673561.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认魔陷区是否有空位，若已无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地移动到自己的魔法与陷阱区域并表侧表示，同时立即适用其作为永续魔法的场上的效果。
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
