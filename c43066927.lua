--ミミグル・フェアリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。自己场上有「迷拟宝箱鬼」怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●这个回合，自己不能把从自身手卡特殊召唤的怪兽的效果发动。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册该卡的两个效果：②反转诱发效果（控制权转移+禁止发动从手卡特殊召唤的怪兽效果）和①起动效果（手牌特殊召唤到对方/自己场上），并分别设置1回合1次的限制。
function s.initial_effect(c)
	-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。●这个回合，自己不能把从自身手卡特殊召唤的怪兽的效果发动。●这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 设置该反转效果的发动条件为“主要阶段”（由Mimighoul通用条件限制，即只能在主要阶段中反转时才能发动）。
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
-- 反转效果的发动判定：无需取对象即可发动；同时向系统登记本连锁将进行控制权变更。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为本效果涉及改变控制权，目标为效果发动者场上的这张卡（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 反转效果处理：给发动者tp注册一个本回合不能发动“从自身手卡特殊召唤的怪兽”效果的禁效；然后若这张卡仍与效果关联，则中断连锁处理，把这张卡的控制权移给对方。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。自己场上有「迷拟宝箱鬼」怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。②：这张卡在主要阶段反转的场合发动。以下效果各适用。●这个回合，自己不能把从自身手卡特殊召唤的怪兽的效果发动。●这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚刚创建的禁效效果e1注册到玩家tp，使其在场上生效，直到回合结束。
	Duel.RegisterEffect(e1,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使接下来的控制权转移被视为一次新的处理，避免与前面的禁效合并处理（防止错过时点）。
		Duel.BreakEffect()
		-- 把这张卡（c）的控制权转移给对方玩家（1-tp）。
		Duel.GetControl(c,1-tp)
	end
end
-- 定义禁效的判定逻辑：被发动的效果必须是怪兽效果的发动，且该怪兽是特殊召唤、位于怪兽区域、其召唤前的控制者为本回合被禁的tp、且是从手卡特殊召唤出来的。
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE)
		and rc:GetPreviousControler()==tp and rc:IsSummonLocation(LOCATION_HAND)
end
-- 定义“在自己场上表侧表示特殊召唤”的可行性：自己场上有表侧表示的「迷拟宝箱鬼」怪兽，且这张卡能够以表侧表示被特殊召唤。
function s.sspfilter(c,tp,e)
	-- 检查自己场上是否存在1张表侧表示的「迷拟宝箱鬼」系列怪兽（setcode 0x1b7）。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x1b7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 定义“在对方场上里侧守备表示特殊召唤”的可行性：这张卡能否以里侧守备表示特殊召唤到对方场上。
function s.ospfilter(c,tp,e)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
-- ①效果的发动条件判定：只要满足“可在自己场上表侧特殊召唤且己方区域有空位”或“可在对方场上里侧特殊召唤且对方区域有空位”任一条件即可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 条件分支前半：如果可以在己方场上表侧表示特殊召唤，并且己方主要怪兽区域有空位，则满足发动条件。
	if chk==0 then return s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件分支后半：或者可以在对方场上里侧守备表示特殊召唤，并且对方主要怪兽区域有空位，也满足发动条件。
		or s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置操作信息为本效果涉及特殊召唤，目标为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联且仍有可行的特殊召唤选项，则让玩家选择特殊召唤到哪里；选择己方则表侧表示，选择对方则里侧守备表示并让对方确认；若双方都没有空位则规则送墓。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not s.sspfilter(c,tp,e) and not s.ospfilter(c,tp,e)) then return end
	-- 计算选项1（自己场上表侧特殊召唤）是否可行：满足自身召唤条件且己方主要怪兽区域有空位。
	local b1=s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 计算选项2（对方场上里侧特殊召唤）是否可行：满足对方场里侧召唤条件且对方主要怪兽区域有空位。
	local b2=s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	-- 弹出选择框，让玩家从可行的特殊召唤位置中选择一个，返回目标玩家（tp=自己，1-tp=对方）。
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),tp},  --"在自己场上特殊召唤"
		{b2,aux.Stringid(id,3),1-tp})  --"在对方场上特殊召唤"
	if toplayer==tp then
		-- 在选择自己场上的情况下，将这张卡以表侧表示（POS_FACEUP）在自己场上特殊召唤。
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	elseif toplayer==1-tp then
		-- 在选择对方场上的情况下，将这张卡在对方场上以里侧守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 由于里侧表示特殊召唤的怪兽对方看不到，向tp玩家确认这张卡，使其确认里侧表示特殊召唤的怪兽。
		Duel.ConfirmCards(tp,c)
	else
		-- 当己方与对方场上均没有可用的主要怪兽区域空位时（两个选项都无法执行）。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 因规则处理将这张卡送去墓地（规则送墓）。
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
