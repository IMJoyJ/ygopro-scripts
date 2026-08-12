--GMX同絆者セランディア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只「基因组混合」怪兽或恐龙族怪兽特殊召唤。这个回合，自己不用「基因组混合」怪兽不能直接攻击。
-- ②：这张卡用怪兽的效果特殊召唤的场合才能发动。自己的手卡·墓地·除外状态的4星以下的1只「基因组混合」怪兽或恐龙族怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册①效果（手卡发动的起动效果，给对方观看此卡为代价，从手卡特殊召唤1只「基因组混合」或恐龙族怪兽，并附加本回合非「基因组混合」怪兽不能直接攻击的限制，1回合1次）和②效果（这张卡特殊召唤成功时发动的诱发选发效果，从手卡·墓地·除外状态守备表示特殊召唤1只4星以下的「基因组混合」或恐龙族怪兽，1回合1次）
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只「基因组混合」怪兽或恐龙族怪兽特殊召唤。这个回合，自己不用「基因组混合」怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	-- ②：这张卡用怪兽的效果特殊召唤的场合才能发动。自己的手卡·墓地·除外状态的4星以下的1只「基因组混合」怪兽或恐龙族怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡·墓地·除外状态特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：要求这张卡尚未公开，把手卡的这张卡给对方观看，然后洗切自己的手卡
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	-- 把手卡的这张卡给对方观看（让对方确认这张卡）
	Duel.ConfirmCards(1-tp,c)
	-- 洗切自己的手卡，使对方无法根据位置辨认刚才展示的卡
	Duel.ShuffleHand(tp)
end
-- 特殊召唤对象的过滤条件：是「基因组混合」怪兽或恐龙族怪兽，且可以被特殊召唤
function s.spfilter1(c,e,tp)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件检查：自己的主要怪兽区有空位，且手卡存在可以特殊召唤的「基因组混合」或恐龙族怪兽
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1只满足条件的可以特殊召唤的「基因组混合」或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：宣言本次连锁将要从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理：先给全场注册「非『基因组混合』怪兽本回合不能直接攻击」的限制效果，然后玩家从手卡选择1只满足条件的怪兽表侧表示特殊召唤
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 从手卡把1只「基因组混合」怪兽或恐龙族怪兽特殊召唤。这个回合，自己不用「基因组混合」怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.dirlim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「不能直接攻击」的限制效果注册为发动玩家的场上效果
	Duel.RegisterEffect(e1,tp)
	-- 如果自己的主要怪兽区没有空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的可以特殊召唤的「基因组混合」或恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 把选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 不能直接攻击限制的作用对象过滤：除「基因组混合」怪兽以外的怪兽不能直接攻击
function s.dirlim(e,c)
	return not c:IsSetCard(0x1dd)
end
-- ②效果的发动条件：这张卡是用怪兽的效果特殊召唤的（诱发效果来源为怪兽效果）
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ②效果特殊召唤对象的过滤条件：4星以下的「基因组混合」怪兽或恐龙族怪兽，可以守备表示特殊召唤，且处于表侧或除外状态
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsFaceupEx()
end
-- ②效果的发动条件检查：自己的主要怪兽区有空位，且手卡·墓地·除外状态存在满足条件的可以特殊召唤的怪兽
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地·除外状态是否存在至少1只满足条件的可以特殊召唤的4星以下「基因组混合」或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：宣言本次连锁将要从手卡·墓地·除外状态特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理：确认主要怪兽区有空位后，让玩家从手卡·墓地·除外状态选择1只满足条件的怪兽（受王家长眠之谷影响时需选不受其影响的卡），守备表示特殊召唤
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己的主要怪兽区没有空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地·除外状态选择1只满足条件的可以特殊召唤的怪兽（墓地中的卡附加王家长眠之谷过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 把选择的怪兽以守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
