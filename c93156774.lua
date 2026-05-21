--VS ホーリー・スー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己·对方的主要阶段，把手卡1只其他的「征服斗魂」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●地·暗：对方场上1只攻击力最低的怪兽的控制权直到结束阶段得到。
-- ●炎·暗：从卡组把1只念动力族以外的「征服斗魂」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①②效果
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次：自己·对方的主要阶段，把手卡1只其他的「征服斗魂」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果中，展示地·暗属性怪兽发动的分支：对方场上1只攻击力最低的怪兽的控制权直到结束阶段得到。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"地·暗属性"
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.ctcost)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果中，展示炎·暗属性怪兽发动的分支：从卡组把1只念动力族以外的「征服斗魂」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"炎·暗属性"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 定义①效果的发动条件判定函数
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己或对方的主要阶段
	return Duel.IsMainPhase()
end
-- 过滤手卡中未公开的「征服斗魂」怪兽卡
function s.spcostfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 定义①效果的发动代价（Cost）函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段，检查手卡中是否存在除这张卡以外的、满足过滤条件的「征服斗魂」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只其他的「征服斗魂」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 给对方玩家确认所选择的怪兽卡
	Duel.ConfirmCards(1-tp,g)
	-- 触发展示手卡怪兽的自定义事件时点
	Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切发动玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 定义①效果的发动目标（Target）函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查这张卡是否可以特殊召唤，并确保在同一连锁上没有发动过同名卡的效果
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册连锁内发动标识，用于限制同一连锁不能发动同名卡的其他效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置特殊召唤的操作信息，准备将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义①效果的效果处理（Operation）函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡往自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中未公开的地属性或暗属性怪兽卡
function s.ctcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 定义②效果（地·暗分支）的发动代价（Cost）函数
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有满足过滤条件的地·暗属性怪兽组
	local g=Duel.GetMatchingGroup(s.ctcostfilter,tp,LOCATION_HAND,0,nil)
	-- 在发动阶段，检查手卡中是否存在可以分别满足地属性和暗属性的2张怪兽卡组合
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中地属性和暗属性的怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK)
	-- 给对方玩家确认所选择的2张怪兽卡
	Duel.ConfirmCards(1-tp,sg)
	-- 触发展示手卡怪兽的自定义事件时点
	Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切发动玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 过滤场上表侧表示的怪兽
function s.ctfilter(c)
	return c:IsFaceup()
end
-- 定义②效果（地·暗分支）的发动目标（Target）函数
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
		if #g<=0 then return false end
		local tg=g:GetMinGroup(Card.GetAttack):Filter(Card.IsControlerCanBeChanged,nil)
		-- 检查是否存在可改变控制权的攻击力最低怪兽、自己场上是否有控制权转移所需的怪兽区域空格，并确保同一连锁上未发动过同名卡效果
		return tg:GetCount()>0 and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and Duel.GetFlagEffect(tp,id)==0
	end
	-- 为玩家注册连锁内发动标识，用于限制同一连锁不能发动同名卡的其他效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置控制权转移的操作信息，准备夺取对方场上1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 定义②效果（地·暗分支）的效果处理（Operation）函数
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	-- 若对方场上没有表侧表示怪兽，或自己场上没有可用于控制权转移的怪兽区域空格，则效果不处理
	if g:GetCount()<=0 or Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)<=0 then return end
	local tg=g:GetMinGroup(Card.GetAttack):Filter(Card.IsControlerCanBeChanged,nil)
	local tc=tg:GetFirst()
	if tg:GetCount()>1 then
		-- 提示玩家选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		local sg=tg:Select(tp,1,1,nil)
		-- 手动为被选择的怪兽显示被选为对象的动画效果
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	end
	-- 直到结束阶段得到目标怪兽的控制权
	Duel.GetControl(tc,tp,PHASE_END,1)
end
-- 过滤手卡中未公开的炎属性或暗属性怪兽卡
function s.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 定义②效果（炎·暗分支）的发动代价（Cost）函数
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有满足过滤条件的炎·暗属性怪兽组
	local g=Duel.GetMatchingGroup(s.descfilter,tp,LOCATION_HAND,0,nil)
	-- 在发动阶段，检查手卡中是否存在可以分别满足炎属性和暗属性的2张怪兽卡组合
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中炎属性和暗属性的怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK)
	-- 给对方玩家确认所选择的2张怪兽卡
	Duel.ConfirmCards(1-tp,sg)
	-- 触发展示手卡怪兽的自定义事件时点
	Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 洗切发动玩家的手卡
	Duel.ShuffleHand(tp)
end
-- 过滤卡组中可以特殊召唤的念动力族以外的「征服斗魂」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x195) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsRace(RACE_PSYCHO)
end
-- 定义②效果（炎·暗分支）的发动目标（Target）函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足过滤条件的怪兽，并确保同一连锁上未发动过同名卡效果
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册连锁内发动标识，用于限制同一连锁不能发动同名卡的其他效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置特殊召唤的操作信息，准备从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果（炎·暗分支）的效果处理（Operation）函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
