--光の継承
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：和已在场上存在的怪兽相同种类（仪式·融合·同调·超量）的怪兽仪式·融合·同调·超量召唤的场合才能发动。自己从卡组抽1张。
function c48784854.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：和已在场上存在的怪兽相同种类（仪式·融合·同调·超量）的怪兽仪式·融合·同调·超量召唤的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48784854,0))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,48784854)
	e2:SetCondition(c48784854.drcon)
	e2:SetTarget(c48784854.drtg)
	e2:SetOperation(c48784854.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示，且其种类（仪式/融合/同调/超量）与刚特殊召唤的怪兽的召唤种类位（sumtype）有交集，用于筛选场上已存在的同种类怪兽。
function c48784854.typfilter(c,sumtype)
	return c:IsFaceup() and c:GetType()&sumtype>0
end
-- 过滤函数：判断刚特殊召唤的怪兽c是否为表侧表示，且召唤类型属于仪式/融合/同调/超量之一；同时检查场上（除c自身外）是否存在至少1只与c具有相同召唤种类位的表侧表示怪兽，从而满足发动条件。
function c48784854.cfilter(c,tp)
	local sumtype=bit.band(c:GetType(),TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ)
	return c:IsFaceup()
		and (c:IsSummonType(SUMMON_TYPE_RITUAL) or c:IsSummonType(SUMMON_TYPE_FUSION)
			or c:IsSummonType(SUMMON_TYPE_SYNCHRO) or c:IsSummonType(SUMMON_TYPE_XYZ))
		-- 从双方场上主要怪兽区检索是否存在至少1只除c以外、表侧表示且类型与c的召唤种类相同的怪兽，即确认场上已经有同种类的怪兽存在。
		and Duel.IsExistingMatchingCard(c48784854.typfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,sumtype)
end
-- 发动条件判断：当特殊召唤成功的怪兽组eg中存在至少1只怪兽满足cfilter条件（该怪兽为仪式/融合/同调/超量召唤，且场上有与之同种类的已有怪兽）时，本效果可以发动。
function c48784854.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48784854.cfilter,1,nil,tp)
end
-- 效果发动时的目标设定与合法性判断：在chk==0时确认自己能否抽1张卡；确认可发动后，将对象玩家设为自己、对象参数设为抽卡数量1，并登记操作信息供效果处理时使用。
function c48784854.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查（chk==0）：若自己不能因效果抽1张卡，则本效果的发动不合法。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的“对象玩家”设为发动者自己（tp），表示抽卡动作的受益玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的“对象参数”设为1，表示后续处理时需要抽取的卡数为1。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本连锁效果类别为抽卡（CATEGORY_DRAW），对象玩家为tp，参数为抽1张；因不取对象，targets为nil，此信息用于相关效果的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：从连锁信息中取出之前设定的对象玩家和抽卡数量，让该玩家以效果原因抽对应数量的卡。
function c48784854.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家p和对象参数d，即抽卡玩家与抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡，完成“自己从卡组抽1张”的结算。
	Duel.Draw(p,d,REASON_EFFECT)
end
