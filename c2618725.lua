--GMX Partner Selandea
-- 效果：
-- 可以把手卡的这张卡给对方出示；从手卡把1只「GMX」怪兽或者恐龙族怪兽特殊召唤，这个回合，自己不用「GMX」怪兽不能直接攻击。
-- 这张卡用怪兽的效果特殊召唤的场合：可以把自己手卡·墓地·除外状态的4星以下的1只「GMX」怪兽或者恐龙族怪兽以守备表示特殊召唤。
-- 「GMX合作伙伴 塞兰特亚」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册“GMX合作伙伴 塞兰特亚”的卡片效果：①展示手卡的此卡从手卡特召1只「GMX」或恐龙族怪兽的起动效果，②用怪兽效果特召成功时，特召手卡·墓地·除外状态的4星以下「GMX」或恐龙族怪兽的诱发效果
function s.initial_effect(c)
	-- ①：可以把手卡的这张卡给对方出示；从手卡把1只「GMX」怪兽或者恐龙族怪兽特殊召唤，这个回合，自己不用「GMX」怪兽不能直接攻击。
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
	-- ②：这张卡用怪兽的效果特殊召唤的场合：可以把自己手卡·墓地·除外状态的4星以下的1只「GMX」怪兽或者恐龙族怪兽以守备表示特殊召唤。
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
-- 效果①的Cost处理：验证是否可发动，并将手卡中的这张卡展示给对方确认，随后洗牌
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	-- 将手卡中的这张卡展示给对方确认
	Duel.ConfirmCards(1-tp,c)
	-- 手动切洗发动玩家的手牌
	Duel.ShuffleHand(tp)
end
-- 过滤条件：手卡中的「GMX」怪兽或恐龙族怪兽，且可以特殊召唤
function s.spfilter1(c,e,tp)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：判断自己场上是否有空闲的怪兽区域，以及手卡是否存在可特召的目标，并设置特殊召唤的操作信息
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上的主要怪兽区域是否还有空余的格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己手卡中是否存在符合特召条件的「GMX」怪兽或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的操作处理：在己方场上注册「本回合自己不用GMX怪兽不能直接攻击」的持续效果，若怪兽区有空位，则将手卡1只「GMX」或恐龙族怪兽特殊召唤
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己不用「GMX」怪兽不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.dirlim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制直接攻击的持续效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 检查自己场上的主要怪兽区域是否还有空余格子，若无则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示：请选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：限制除了「GMX」怪兽以外的怪兽进行直接攻击
function s.dirlim(e,c)
	return not c:IsSetCard(0x1dd)
end
-- 效果②的发动条件：此卡是用怪兽的效果特殊召唤成功的场合
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件：手卡·墓地·除外状态的等级4以下的「GMX」怪兽或恐龙族怪兽，且可以守备表示特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and c:IsFaceupEx()
end
-- 效果②的发动准备：判断自己场上是否有空闲怪兽区域，以及各区域是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上的主要怪兽区域是否还有空余的格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡·墓地·除外状态中是否存在等级4以下的符合特召条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡·墓地·除外状态特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的操作处理：若怪兽区有空位，则特召手卡·墓地·除外状态的4星以下的1只「GMX」怪兽或者恐龙族怪兽以守备表示特殊召唤
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否还有空位，若无则直接结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示：请选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只符合条件且不受王家之谷影响（若在墓地）的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽在自己场上以守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
