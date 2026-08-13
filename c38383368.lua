--エキストラケアトップス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，额外怪兽区域的怪兽被和主要怪兽区域的怪兽的战斗破坏送去墓地时才能发动。这张卡在那只破坏的额外怪兽区域的怪兽的持有者场上守备表示特殊召唤。
-- ②：这张卡的①的效果特殊召唤的这张卡被破坏送去墓地的场合发动。自己从卡组抽1张。
function c38383368.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在墓地存在，额外怪兽区域的怪兽被和主要怪兽区域的怪兽的战斗破坏送去墓地时才能发动。这张卡在那只破坏的额外怪兽区域的怪兽的持有者场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38383368,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,38383368)
	e1:SetTarget(c38383368.sptg)
	e1:SetOperation(c38383368.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤的这张卡被破坏送去墓地的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c38383368.drcon)
	e2:SetTarget(c38383368.drtg)
	e2:SetOperation(c38383368.drop)
	c:RegisterEffect(e2)
end
-- 过滤“额外怪兽区域被主要怪兽区域怪兽战斗破坏的怪兽”：该怪兽需是因战斗被破坏且之前位于额外怪兽区（序号>=5），且其战斗对象是（或原本是）主要怪兽区（序号<5）的怪兽。
function c38383368.cfilter(c)
	if not (c:IsReason(REASON_BATTLE) and c:GetPreviousSequence()>=5) then return false end
	local d=c:GetBattleTarget()
	return d:IsRelateToBattle() and d:GetSequence()<5 or not d:IsRelateToBattle() and d:GetPreviousSequence()<5
end
-- ①效果的发动条件判定：从本次送去墓地的怪兽中筛选出符合条件的额外怪兽区域战斗破坏怪兽；若这张卡不在其中、存在符合条件的怪兽、该怪兽控制者场上有可用的特殊召唤空格，且这张卡可以表侧守备特殊召唤到其控制者场上，则允许发动。
function c38383368.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=eg:Filter(c38383368.cfilter,nil):GetFirst()
	-- 检查本次送去墓地的怪兽中不包含这张卡自身、存在符合条件的怪兽、该怪兽的控制者场上有可用的主要怪兽区空格。
	if chk==0 then return not eg:IsContains(c) and tc and Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tc:GetControler()) end
	e:SetLabel(tc:GetControler())
	-- 登记本次连锁的特殊召唤操作信息：对象为本卡，数量为1，用于后续效果处理和发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，将其特殊召唤到此前记录的目标玩家（被战斗破坏的额外怪兽的持有者）的场上，表侧守备表示。
function c38383368.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以自身效果特殊召唤的方式，将这张卡表侧守备特殊召唤到e:GetLabel()记录的玩家（被战斗破坏的额外怪兽的持有者）的场上。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,e:GetLabel(),false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件：这张卡是被破坏并送去墓地，且被破坏前位于场上怪兽区域，并且其召唤类型为‘自身效果的特殊召唤’（即由①效果特殊召唤的），满足时强制发动。
function c38383368.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果的发动目标设定：无选择对象，必定发动；设置抽卡玩家为自己、抽卡数量为1，并登记抽卡操作信息。
function c38383368.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者（自己），即抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记抽卡操作信息：抽卡玩家为自己，数量为1，供后续效果处理和其他效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从连锁信息中取出目标玩家和抽卡数量，执行抽卡；抽卡原因为效果。
function c38383368.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家（抽卡者）和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
