--超巨大戦艦 メタル・スレイブ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡·卡组把最多5只10星以下的「巨大战舰」怪兽送去墓地才能发动（同名卡最多1张）。这张卡从手卡特殊召唤。那之后，为这个效果发动而送去墓地的数量的指示物给这张卡放置。
-- ②：自己·对方回合，把这张卡1个指示物取除，以包含自己场上的「巨大战舰」怪兽的场上2张表侧表示卡为对象才能发动（同一连锁上最多1次）。那些卡破坏。
local s,id,o=GetID()
-- 初始化效果：允许此卡放置0x1f指示物；创建并注册①号起动效果（手卡发动、1回合1次，cost/目标/处理分别指定）；创建并注册②号诱发即时效果（场上发动、取对象、同一连锁最多1次，cost/目标/处理分别指定）。
function s.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这个卡名的①的效果1回合只能使用1次。①：从手卡·卡组把最多5只10星以下的「巨大战舰」怪兽送去墓地才能发动（同名卡最多1张）。这张卡从手卡特殊召唤。那之后，为这个效果发动而送去墓地的数量的指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡1个指示物取除，以包含自己场上的「巨大战舰」怪兽的场上2张表侧表示卡为对象才能发动（同一连锁上最多1次）。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- cost过滤函数：作为①效果cost送去墓地的卡必须满足：属于「巨大战舰」系列、等级10以下、可以作为cost送去墓地。
function s.costfilter(c)
	return c:IsSetCard(0x15) and c:IsLevelBelow(10) and c:IsAbleToGraveAsCost()
end
-- ①效果的cost处理：先从手卡·卡组获取所有满足costfilter的候选卡；在合法性检查时只需确认存在至少1张可送墓的卡；实际发动时提示玩家选择1~5张卡名互不相同的满足条件的卡送去墓地，并将选择数量记录到效果label，供后续放置指示物。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方手卡·卡组中所有满足costfilter的卡组成的集合g，用于后续选择cost。
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	-- 若为发动合法性检查（chk==0），则判断手卡·卡组是否存在至少1张满足costfilter的卡，作为cost能否支付的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 显示选择卡片提示消息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从候选集合g中选择1~5张卡，要求卡名各不相同（aux.dncheck），作为cost送去墓地。
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,5)
	-- 将选择的卡作为cost送去墓地。
	Duel.SendtoGrave(tg,REASON_COST)
	e:SetLabel(tg:GetCount())
end
-- ①效果的目标判定函数：发动条件包括cost已满足、自己主要怪兽区有空位、此卡自身能被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上主要怪兽区是否有空位，用于从手卡特殊召唤此卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将进行特殊召唤，对象为此卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将此卡从手卡特殊召唤；若召唤成功、cost送去墓地的数量大于0且此卡能够放置0x1f指示物，则中断效果处理（错时点）后，为此卡放置对应数量的指示物。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡仍与当前连锁相关（未被无效或离场）且特殊召唤成功。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and e:GetLabel()>0 and c:IsCanAddCounter(0x1f,e:GetLabel()) then
		-- 中断当前效果处理，使特殊召唤与后续放置指示物视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		c:AddCounter(0x1f,e:GetLabel())
	end
end
-- ②效果的cost处理：取除此卡1个0x1f指示物作为发动代价；合法性检查时判断是否可以取除。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1f,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_COST)
end
-- 对象候选过滤函数：作为②效果对象的卡需要是表侧表示且当前效果能以其为对象。
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
-- 用于判断所选择的2张卡中是否包含至少1张自己场上的表侧表示「巨大战舰」怪兽。
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x15) and c:IsControler(tp)
end
-- 子组选择函数：从候选组中选出2张卡，其中至少包含1张满足desfilter的自己场上的「巨大战舰」怪兽。
function s.fselect(g,tp)
	return g:IsExists(s.desfilter,1,nil,tp)
end
-- ②效果的目标判定与选择：不可再取对象；获取场上所有表侧且可被取对象的卡；合法性检查时确认存在2张卡组成的子组满足至少包含1张自己「巨大战舰」怪兽；实际选择时提示玩家选择2张卡，设为对象并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上双方所有满足cfilter（表侧表示且可成为效果对象）的卡集合rg，作为后续选择的对象候选。
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return rg:CheckSubGroup(s.fselect,2,2,tp) end
	-- 显示选择卡片提示消息，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=rg:SelectSubGroup(tp,s.fselect,false,2,2,tp)
	-- 将选中的2张卡设为当前连锁的对象（取对象）。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：本次效果将破坏选中的对象，数量为选中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
-- ②效果处理：破坏与连锁相关的对象卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前连锁相关的对象卡全部破坏（原因：效果）。
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
