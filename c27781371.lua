--天地再世
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「再世」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：对方回合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·墓地·除外状态的「再世」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段送去墓地。
local s,id,o=GetID()
-- 创建并注册该卡的全部效果：e1为允许魔陷发动的空效果；e2为①效果（送墓「再世」怪兽并翻转对方怪兽）；e3为②效果（对方回合送墓自身并特殊召唤「再世」怪兽）；e2与e3通过SetCountLimit(1,id)实现这个卡名的①②效果1回合只能有1次使用其中任意1个。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从卡组把1只「再世」怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.poscost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：对方回合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·墓地·除外状态的「再世」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽在结束阶段送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果发动cost的筛选条件：卡组中的「再世」字段怪兽且可以送去墓地作为cost。
function s.costfilter(c)
	return c:IsSetCard(0x1c5) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动cost：若卡组存在符合条件的「再世」怪兽，则从中选择1只送去墓地作为代价。
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：确认卡组中至少有1只满足costfilter的「再世」怪兽用于送墓。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 弹出提示，要求玩家选择要送去墓地的1张「再世」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选出1张满足costfilter的「再世」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地，作为发动①效果的cost。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义①效果的取对象筛选：对方场上的表侧表示怪兽，且能够被变成里侧守备表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的取对象目标选择：检查存在符合条件的对方表侧怪兽后，选择1只作为效果对象，并设置操作信息为改变表示形式。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 目标检查阶段：确认对方场上有至少1只表侧表示且可被翻转成里侧守备表示的怪兽可取对象。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出提示，要求玩家选择1只表侧表示怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上的1只满足posfilter的表侧表示怪兽，并将其登记为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁将把对象怪兽的表示形式改变（CATEGORY_POSITION），目标为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果处理：取得对象怪兽，确认其仍与效果关联且是怪兽后，将其变为里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的唯一对象怪兽（由SelectTarget登记）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将对象怪兽的表示形式改变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动条件判断：仅当当前是对方回合时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方玩家（tp的对手），是则条件成立。
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的cost：确认这张表侧表示的魔法卡仍在魔陷区且效果有效、可作为cost送去墓地，然后将其送墓。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡自身送去墓地，作为发动②效果的cost。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 定义可被②效果特殊召唤的「再世」怪兽筛选条件：位于手卡·墓地·除外状态，属于「再世」字段，且能被此效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1c5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件：自己的主要怪兽区有空位，且手卡·墓地·除外状态中存在至少1只符合条件的「再世」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用空格，确保能进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地·除外状态中是否存在至少1只满足spfilter的「再世」怪兽作为候选。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），来源为手卡·墓地·除外状态，预计至少处理1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果处理：取得所有可特殊召唤的「再世」怪兽，结合空位数量与不同卡名数量决定可召唤的最大数量；若青眼精灵龙效果适用则至多1只；然后让玩家选择要召唤的卡，以表侧攻击表示逐只特殊召唤，并为这些怪兽注册结束阶段送去墓地的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有位于手卡·墓地·除外的「再世」候选怪兽组，并通过王家长眠之谷过滤，排除不能从墓地特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	-- 计算本次可特殊召唤的最大数量ft：取主要怪兽区空位数与候选组中不同卡名数（同名最多1张）的较小值。
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出提示，要求玩家选择要特殊召唤的「再世」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选择ft张卡，且这些卡的卡名互不相同（对应同名卡最多1张），实际选择数量为可召唤的最大数量ft。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ft,ft)
	if sg then
		local fid=e:GetHandler():GetFieldID()
		-- 遍历已选择要特殊召唤的每张「再世」怪兽，准备依次进行特殊召唤处理。
		for tc in aux.Next(sg) do
			-- 将当前这张「再世」怪兽以表侧攻击表示特殊召唤（遵守苏生限制和召唤条件），并加入本次特殊召唤处理批次。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		sg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(s.tgcon)
		e1:SetOperation(s.tgop)
		-- 将结束阶段时把本次特殊召唤的怪兽送去墓地的持续效果注册到场上。
		Duel.RegisterEffect(e1,tp)
		-- 完成批次特殊召唤处理（SpecialSummonStep的配套调用），使前面各步特殊召唤正式生效。
		Duel.SpecialSummonComplete()
	end
end
-- 定义tcfilter：判定一张卡是否带有本次效果赋予的字段标记fid，用于识别哪些是本次特殊召唤的怪兽。
function s.tcfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段送墓效果的condition：若场上仍存在带有本次fid标记的怪兽，则执行送墓；否则清理并重置该效果。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
	if not g or g:FilterCount(s.tcfilter,nil,fid)==0 then
		if g then g:DeleteGroup() end
		e:Reset()
		return false
	else return true end
end
-- 结束阶段送墓效果的处理：筛选出仍带有本次fid标记的怪兽，准备送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local g=e:GetLabelObject()
	local sg=g:Filter(s.tcfilter,nil,fid)
	-- 将本次特殊召唤且仍留在场上的「再世」怪兽送去墓地（效果送墓）。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
