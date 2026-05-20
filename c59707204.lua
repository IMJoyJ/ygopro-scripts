--護神鳥シムルグ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
function c59707204.initial_effect(c)
	-- ①：这张卡召唤成功时，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59707204,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,59707204)
	e1:SetTarget(c59707204.thtg)
	e1:SetOperation(c59707204.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的魔法与陷阱区域没有卡存在的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59707204,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,59707205)
	e2:SetCondition(c59707204.spcon)
	e2:SetTarget(c59707204.sptg)
	e2:SetOperation(c59707204.spop)
	c:RegisterEffect(e2)
end
-- 过滤对方魔法与陷阱区域（不含场地区）且能回到手牌的卡片
function c59707204.thfilter(c)
	return c:GetSequence()<5 and c:IsAbleToHand()
end
-- 效果①的发动准备与靶向阶段，检查并选择对方魔陷区的一张卡作为对象，并设置操作信息
function c59707204.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c59707204.thfilter(chkc) end
	-- 检查对方魔法与陷阱区域（不含场地区）是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingTarget(c59707204.thfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方魔法与陷阱区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c59707204.thfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置效果处理信息，表示该连锁将要把选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理阶段，获取对象卡片，若其仍符合条件则将其送回持有者手牌
function c59707204.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将对象卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤魔法与陷阱区域（不含场地区）的卡片
function c59707204.cfilter(c)
	return c:GetSequence()<5
end
-- 效果②的发动条件判定函数，检查对方魔法与陷阱区域是否没有卡存在
function c59707204.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方的魔法与陷阱区域（不含场地区）是否不存在任何卡
	return not Duel.IsExistingMatchingCard(c59707204.cfilter,tp,0,LOCATION_SZONE,1,nil)
end
-- 效果②的发动准备阶段，检查自身是否能特殊召唤以及怪兽区域是否有空位，并设置特殊召唤的操作信息
function c59707204.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理信息，表示该连锁将要把自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理阶段，将自身守备表示特殊召唤，并适用离场除外以及鸟兽族特召限制
function c59707204.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧守备表示特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 这个效果的发动后，直到回合结束时自己不是鸟兽族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59707204.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤鸟兽族以外怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非鸟兽族的怪兽
function c59707204.splimit(e,c)
	return not c:IsRace(RACE_WINDBEAST)
end
