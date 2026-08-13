--空牙団の疾風 レクス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从手卡把「空牙团的疾风 雷克斯」以外的1只「空牙团」怪兽特殊召唤。那之后，这张卡特殊召唤。
-- ②：「空牙团」卡以外的效果从卡组让卡加入对方手卡的场合，若自己场上有其他的「空牙团」怪兽存在则能发动。自己抽1张。
local s,id,o=GetID()
-- 初始化效果注册：e1为①起动效果（手牌中展示自身发动，从手卡特殊召唤1只「空牙团的疾风 雷克斯」以外的「空牙团」怪兽，那之后自身特殊召唤；同名卡①效果1回合1次）；e2为②诱发选发效果（「空牙团」卡以外的效果使卡从卡组加入对方手卡且自己场上有其他「空牙团」怪兽存在时，自己抽1张；同一连锁最多发动1次）。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把手卡的这张卡给对方观看才能发动。从手卡把「空牙团的疾风 雷克斯」以外的1只「空牙团」怪兽特殊召唤。那之后，这张卡特殊召唤。
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
	-- ②：「空牙团」卡以外的效果从卡组让卡加入对方手卡的场合，若自己场上有其他的「空牙团」怪兽存在则能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价判定：这张卡必须处于手牌且当前为非公开状态，才能通过‘给对方观看’支付代价；若已公开则不能发动。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 筛选可被①效果从手卡特殊召唤的卡：属于「空牙团」系列、卡名不是「空牙团的疾风 雷克斯」、且满足特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标合法性检查：确认我方主要怪兽区空位>1、本回合还可特殊召唤2次、手牌存在符合条件的「空牙团」怪兽、且自身可特殊召唤；满足则允许发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方主要怪兽区是否有至少2个空格，以容纳即将特殊召唤的1只「空牙团」怪兽和这张卡自身。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查我方本回合还能进行2次特殊召唤（因为效果会一口气特殊召唤2只怪兽）。
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查手牌中是否存在至少1只不是本卡且可特殊召唤的「空牙团」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设为：从手卡特殊召唤2只怪兽。因具体对象在处理时选择，targets设为nil，count为2，目标玩家为tp，位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- ①效果处理：先从手卡选择1只满足条件的「空牙团」怪兽并特殊召唤；若成功且自身仍与连锁关联并可特殊召唤，则中断当前效果处理，再把这张卡自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理开始前若我方主要怪兽区没有空位，则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给操作者发送选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从手卡中选择1只满足条件的「空牙团」怪兽作为要特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若确实选择了卡，且将该卡特殊召唤成功（返回值不为0），才继续执行后续的自身特殊召唤。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsRelateToChain() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 中断当前效果处理，使此后的特殊召唤与之前的特殊召唤错开时点（保持‘那之后’的语义）。
		Duel.BreakEffect()
		-- 将这张卡自身以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于筛选本次加入手卡的卡：其当前控制者是对方玩家，且移动前位于卡组，即从卡组加入了对方手卡。
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- ②效果的发动条件：本次加入手卡事件中存在从卡组加入对方手卡的卡，且触发该事件的效果存在并属于「空牙团」以外的卡的效果。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp) and re and not re:GetHandler():IsSetCard(0x114)
end
-- 用于检查表侧表示的「空牙团」怪兽（调用时会排除这张卡自身）。
function s.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- ②效果的发动目标判定：我方可以抽1张卡，并且自己场上有其他表侧表示的「空牙团」怪兽；满足后设置目标玩家为自己、抽卡数为1，并登记操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定我方是否可以通过效果抽1张卡（即未受到‘不能抽卡’效果限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 判定自己场上是否存在除这张卡以外的表侧表示「空牙团」怪兽（利用ex参数排除自身）。
		and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 将当前连锁的目标玩家设为自己，表示抽卡者是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果：目标玩家tp，预计抽1张卡；因抽出的卡从卡组随机抽出，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：读取连锁中记录的目标玩家和抽卡数量，执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家（抽卡者）和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
