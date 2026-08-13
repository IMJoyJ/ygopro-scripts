--Couple of Aces
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。进行1次投掷硬币。表的场合，这张卡在自己场上特殊召唤。里的场合，这张卡在对方场上特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功的场合发动。自己从卡组抽2张。
local s,id,o=GetID()
-- 此函数为卡片的初始化入口，创建并注册两个效果：效果1为手牌起动效果，进行硬币判定后特殊召唤自身；效果2为通过自身①效果特殊召唤成功时触发的抽卡效果。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡存在的场合才能发动。进行1次投掷硬币。表的场合，这张卡在自己场上特殊召唤。里的场合，这张卡在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功的场合发动。自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- ①效果的发动时点判定与对象/合法性检查：当效果发动时，检查自己或对方的主要怪兽区是否有空位，并且这张卡能否通过自身效果以正面表示特殊召唤到对应玩家场上，以此决定可否发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时点（chk==0）判定自己场上是否存在可用的主要怪兽区，且这张卡能被玩家tp以效果形式特殊召唤到自己场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 在发动时点（chk==0）同时判定对方场上是否存在可用的主要怪兽区，且这张卡能被以正面表示特殊召唤到对方（1-tp）场上。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 将本次连锁的处理信息登记为硬币效果，表示效果处理时需要进行1次投硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 将本次连锁的处理信息登记为特殊召唤效果，对象为本卡，数量为1，用于后续发动条件和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的实际处理函数：先确认这张卡仍与效果关联，然后投1次硬币并据结果将这张卡特殊召唤到自己或对方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 让发动玩家tp投掷1次硬币，返回结果中1代表正面（表），0代表反面（里）。
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		-- 投掷结果为正面时，将这张卡以正面表示特殊召唤到原持有者自己（tp）的场上，召唤类型标记为自身效果特殊召唤。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
	if coin==0 then
		-- 投掷结果为反面时，将这张卡以正面表示特殊召唤到对方（1-tp）的场上，召唤类型标记为自身效果特殊召唤。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：只有当这张卡的召唤类型恰好为“自身效果特殊召唤”时，才能触发后续的抽卡效果。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果的发动时点判定与目标设定：该效果必定发动，登记抽卡对象玩家为自己，抽卡数量为2，并设置连锁操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为发动玩家tp，即后续抽卡效果的对象为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设置为2，表示需要抽取的卡牌数量为2张。
	Duel.SetTargetParam(2)
	-- 将本次连锁的处理信息登记为抽卡效果，对象为空（处理时确定），预计抽卡玩家为tp，数量为2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果的实际处理函数：从连锁信息中取出之前登记的对象玩家和抽卡数量，并让该玩家以效果原因抽对应数量的卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出登记的抽卡对象玩家p和抽卡参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d（2）张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
