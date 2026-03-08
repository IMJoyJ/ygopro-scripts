--ミミグル・フェアリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。自己场上有「迷拟宝箱鬼」怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●这个回合，自己不能把从自身手卡特殊召唤的怪兽的效果发动。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册反转效果和特殊召唤效果
function s.initial_effect(c)
	-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 检查当前是否处于主要阶段
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。自己场上有「迷拟宝箱鬼」怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 设置反转效果的处理信息，指定控制权变更
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 处理反转效果，禁止自己发动特殊召唤的怪兽效果并转移控制权
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 设置禁止自己发动特殊召唤的怪兽效果的永续效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将控制权变更效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，避免错时点
		Duel.BreakEffect()
		-- 使对方获得该卡的控制权
		Duel.GetControl(c,1-tp)
	end
end
-- 限制自己发动特殊召唤的怪兽效果的条件函数
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE)
		and rc:GetPreviousControler()==tp and rc:IsSummonLocation(LOCATION_HAND)
end
-- 检查自己场上是否存在迷拟宝箱鬼怪兽并满足特殊召唤条件
function s.sspfilter(c,tp,e)
	-- 检查自己场上是否存在迷拟宝箱鬼怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x1b7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 检查对方场上是否可以特殊召唤
function s.ospfilter(c,tp,e)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
-- 设置特殊召唤效果的处理信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否可以将该卡在自己场上特殊召唤
	if chk==0 then return s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以将该卡在对方场上特殊召唤
		or s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置操作信息，表示将要特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果，根据选择决定召唤位置
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not s.sspfilter(c,tp,e) and not s.ospfilter(c,tp,e)) then return end
	-- 判断是否可以在自己场上特殊召唤
	local b1=s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断是否可以在对方场上特殊召唤
	local b2=s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	-- 让玩家选择召唤位置
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),tp},  --"在自己场上特殊召唤"
		{b2,aux.Stringid(id,3),1-tp})  --"在对方场上特殊召唤"
	if toplayer==tp then
		-- 在自己场上特殊召唤该卡
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	elseif toplayer==1-tp then
		-- 在对方场上特殊召唤该卡
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 确认对方场上特殊召唤的卡
		Duel.ConfirmCards(tp,c)
	else
		-- 判断是否无法特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 将该卡送入墓地
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
