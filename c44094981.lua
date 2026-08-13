--地縛戒隷 ジオグリフォン
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合可以发动。从自己墓地把「地缚戒隶 地画狮鹫」以外的1只「地缚」怪兽守备表示特殊召唤。这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
-- ②：这张卡被对方破坏的场合才能发动。场上1张卡破坏。那之后，给与对方为自己的场上·墓地的「地缚」怪兽种类×300伤害。
local s,id,o=GetID()
-- 初始化函数：为这张卡加入同调召唤手续，并注册①（即时特殊召唤+自肃）和②（被对方破坏时炸卡+伤害）两个效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续：暗属性调整1只 + 调整以外的怪兽1只以上（数量下限为1，具体由同调素材等级决定）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	-- ①：自己·对方回合可以发动。从自己墓地把「地缚戒隶 地画狮鹫」以外的1只「地缚」怪兽守备表示特殊召唤。这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合才能发动。场上1张卡破坏。那之后，给与对方为自己的场上·墓地的「地缚」怪兽种类×300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 选择条件：自己墓地的「地缚」怪兽，卡名不是本卡，且可以表侧守备表示特殊召唤。
function s.filter(c,e,tp)
	return c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsCode(id)
end
-- ①效果发动时的检查：自己的怪兽区有空位，并且墓地存在满足s.filter的「地缚」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足s.filter的「地缚」怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行从墓地特殊召唤1只怪兽（数量为1，来源位置为墓地）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：若有怪兽区空位，从墓地选择1只「地缚」怪兽守备表示特殊召唤；然后给己方附加本回合只能从额外卡组特殊召唤融合·同调怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己怪兽区是否有空位，防止因连锁变化导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1张满足s.filter的「地缚」怪兽，作为特殊召唤的对象。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。②：这张卡被对方破坏的场合才能发动。场上1张卡破坏。那之后，给与对方为自己的场上·墓地的「地缚」怪兽种类×300伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果作为全场效果注册到己方，影响己方玩家，并在本回合结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃过滤：从额外卡组特殊召唤的怪兽必须是融合或同调怪兽，否则不能特殊召唤。
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- ②发动条件：这张卡被对方破坏（破坏前控制权属于己方，且破坏者是对方）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp
end
-- 用于统计「地缚」怪兽种类的过滤条件：自己场上表侧表示或墓地的「地缚」怪兽。
function s.dfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER)
end
-- ②发动条件：场上存在卡可破坏，并且自己场上·墓地存在至少1只「地缚」怪兽；同时设置破坏与伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上的所有卡牌，作为可能被破坏的候选集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #g>0
		-- 确认自己场上·墓地存在至少1只「地缚」怪兽，保证伤害有计算基准。
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	-- 统计自己场上·墓地的「地缚」怪兽的种类数（按卡名去重），作为伤害倍率。
	local ct=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	-- 设置破坏的操作信息：将场上全部卡作为候选，预定破坏1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害的操作信息：对对方造成种类数×300的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- ②效果处理：选择场上1张卡并破坏；若破坏成功，再根据自己场上·墓地的「地缚」怪兽种类数给予对方伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上全体卡中选择1张要破坏的卡（处理时选择，非发动时取对象）。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	-- 将被选择的卡高亮显示，并记录为广义的选中对象。
	Duel.HintSelection(g)
	-- 以效果原因破坏被选择的卡，并判断是否成功（若被破坏则进入后续伤害阶段）。
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 破坏后重新统计自己场上·墓地的「地缚」怪兽种类数，用最新值计算伤害。
		local ct=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
		if ct>0 then
			-- 中断当前效果链，使后续伤害处理与前面的破坏处理分为不同的时点，避免错过时点。
			Duel.BreakEffect()
			-- 对对方造成ct×300点效果伤害。
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end
