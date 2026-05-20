--ゼノ・メテオロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。选自己的手卡·场上1只恐龙族怪兽破坏。那之后，从手卡·卡组把1只恐龙族通常怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
function c5852388.initial_effect(c)
	-- ①：卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5852388,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,5852388)
	e1:SetCondition(c5852388.spcon)
	e1:SetTarget(c5852388.sptg)
	e1:SetOperation(c5852388.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。选自己的手卡·场上1只恐龙族怪兽破坏。那之后，从手卡·卡组把1只恐龙族通常怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5852388,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,5852389)
	e2:SetTarget(c5852388.dsptg)
	e2:SetOperation(c5852388.dspop)
	c:RegisterEffect(e2)
end
-- 过滤因战斗或效果而被破坏的卡片的条件函数
function c5852388.cfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 检查是否有卡片被战斗或效果破坏，作为效果①的发动条件
function c5852388.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5852388.cfilter,1,nil)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身能否特殊召唤，并设置特殊召唤的操作信息）
function c5852388.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理（若自身仍在手卡，则将自身特殊召唤）
function c5852388.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡或场上可作为破坏对象的恐龙族怪兽，且破坏后能从手卡或卡组特殊召唤恐龙族通常怪兽
function c5852388.desfilter(c,e,tp)
	-- 检查卡片是否为手卡或场上表侧表示的恐龙族怪兽，且该卡离开场后能留出至少一个怪兽区域空位
	return c:IsFaceupEx() and c:IsRace(RACE_DINOSAUR) and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡或卡组中是否存在至少1只满足特殊召唤条件的恐龙族通常怪兽（排除被选为破坏对象的卡本身）
		and Duel.IsExistingMatchingCard(c5852388.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 过滤手卡或卡组中可以特殊召唤的恐龙族通常怪兽的条件函数
function c5852388.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检测（检查是否存在可破坏的恐龙族怪兽，并设置破坏和特殊召唤的操作信息）
function c5852388.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1只满足破坏及后续特召条件的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5852388.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置破坏的操作信息，表示将破坏自己手卡或场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的处理（施加额外卡组特殊召唤限制，选择并破坏1只恐龙族怪兽，之后从手卡或卡组特殊召唤1只恐龙族通常怪兽）
function c5852388.dspop(e,tp,eg,ep,ev,re,r,rp)
	-- 选自己的手卡·场上1只恐龙族怪兽破坏。那之后，从手卡·卡组把1只恐龙族通常怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族·恐龙族·海龙族·幻龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c5852388.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家从额外卡组特殊召唤非特定种族怪兽的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 获取自己手卡及场上所有满足破坏条件的恐龙族怪兽
	local g=Duel.GetMatchingGroup(c5852388.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e,tp)
	if #g==0 then return end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,1,1,nil)
	-- 破坏选中的怪兽，若破坏失败则不处理后续效果
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的恐龙族通常怪兽
	local sg=Duel.SelectMatchingCard(tp,c5852388.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #sg==0 then return end
	-- 中断当前效果处理，使后续的特殊召唤与前面的破坏不视为同时处理（造成错时点）
	Duel.BreakEffect()
	-- 将选中的恐龙族通常怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制玩家不能从额外卡组特殊召唤龙族、恐龙族、海龙族、幻龙族以外的怪兽
function c5852388.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
end
