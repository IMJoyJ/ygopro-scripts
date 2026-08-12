--VS ホーリー・スー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己·对方的主要阶段，把手卡1只其他的「征服斗魂」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●地·暗：对方场上1只攻击力最低的怪兽的控制权直到结束阶段得到。
-- ●炎·暗：从卡组把1只念动力族以外的「征服斗魂」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特召效果以及两个不同属性展示分支的诱发即时效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，把手卡1只其他的「征服斗魂」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
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
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地·暗：对方场上1只攻击力最低的怪兽的控制权直到结束阶段得到。
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
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●炎·暗：从卡组把1只念动力族以外的「征服斗魂」怪兽特殊召唤。
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
-- 设置效果①在自己或对方的主要阶段才能发动的条件函数
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤手卡中未给对方观看的「征服斗魂」怪兽的条件过滤函数
function s.spcostfilter(c)
	return c:IsSetCard(0x195) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果①的发动代价：展示手卡中1只其他的「征服斗魂」怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断手卡是否存在除了自身以外的可以给对方确认的「征服斗魂」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要确认展示给对方的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张满足条件的「征服斗魂」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的卡片展示给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 如果自身是「征服斗魂」卡片，则触发展示手卡的自定义事件以联动其他效果
	if c:IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 将展示卡片后的手卡重新洗牌
	Duel.ShuffleHand(tp)
end
-- 效果①的目标检查函数：判断主怪兽区是否有空位、自身是否可以特殊召唤，以及同一连锁上是否未发动过本效果
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断自己场上的怪兽区域是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自身是否能够特殊召唤，且同一连锁内该卡名的效果未发动过
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册本卡片ID的Flag，用于防止同一连锁内重复发动该卡的效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置连锁处理的操作信息：包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的执行函数：如果自身仍在连锁中，则将自身特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中地属性 and 暗属性怪兽的条件过滤函数
function s.ctcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 效果②分支一的发动代价：展示手卡中的地属性和暗属性怪兽各1只
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡中所有未公开的地属性和暗属性怪兽
	local g=Duel.GetMatchingGroup(s.ctcostfilter,tp,LOCATION_HAND,0,nil)
	-- 检查手卡中是否包含地属性和暗属性的怪兽各1只
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK) end
	-- 提示玩家选择要确认展示给对方的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中地属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_DARK)
	-- 将选中的两张属性怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,sg)
	-- 如果自身是「征服斗魂」怪兽，则触发展示手卡的自定义事件以联动其他效果
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 将展示卡片后的手卡重新洗牌
	Duel.ShuffleHand(tp)
end
-- 过滤对方场上表侧表示怪兽的过滤函数
function s.ctfilter(c)
	return c:IsFaceup()
end
-- 效果②分支一的目标检查与设定：检查对方场上是否存在可夺取控制权的攻击力最低的表侧表示怪兽，检查自己场上的格子，并注册连锁标记和控制权转移操作信息
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
		if #g<=0 then return false end
		local tg=g:GetMinGroup(Card.GetAttack):Filter(Card.IsControlerCanBeChanged,nil)
		-- 检查是否存在可夺取控制权的攻击力最低怪兽、自己怪兽区是否有转移控制权的空位，且该连锁未曾发动过本卡的效果
		return tg:GetCount()>0 and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 and Duel.GetFlagEffect(tp,id)==0
	end
	-- 在当前连锁中注册本卡片ID的Flag，用于防止同一连锁内重复发动该卡的效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置连锁处理的操作信息：包含夺取对方场上1只怪兽控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果②分支一的执行：获取对方场上攻击力最低的表侧表示怪兽控制权，直到结束阶段
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上表侧表示的怪兽
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	-- 若对方场上没有怪兽或自己场上没有能容纳转移控制权怪兽的区域，则不处理
	if g:GetCount()<=0 or Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_CONTROL)<=0 then return end
	local tg=g:GetMinGroup(Card.GetAttack):Filter(Card.IsControlerCanBeChanged,nil)
	local tc=tg:GetFirst()
	if tg:GetCount()>1 then
		-- 提示玩家选择要夺取控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		local sg=tg:Select(tp,1,1,nil)
		-- 在画面上高亮选中的怪兽卡片
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	end
	-- 得到目标怪兽的控制权直到结束阶段
	Duel.GetControl(tc,tp,PHASE_END,1)
end
-- 过滤手卡中炎属性和暗属性怪兽的过滤函数
function s.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE+ATTRIBUTE_DARK) and not c:IsPublic()
end
-- 效果②分支二的发动代价：展示手卡中的炎属性和暗属性怪兽各1只
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡中所有未公开的炎属性和暗属性怪兽
	local g=Duel.GetMatchingGroup(s.descfilter,tp,LOCATION_HAND,0,nil)
	-- 检查手卡中是否包含炎属性和暗属性的怪兽各1只
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK) end
	-- 提示玩家选择要确认展示给对方的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中炎属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_FIRE,ATTRIBUTE_DARK)
	-- 将选中的两张属性怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,sg)
	-- 如果自身是「征服斗魂」怪兽，则触发展示手卡的自定义事件以联动其他效果
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 将展示卡片后的手卡重新洗牌
	Duel.ShuffleHand(tp)
end
-- 过滤卡组中念动力族以外的「征服斗魂」怪兽的过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x195) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsRace(RACE_PSYCHO)
end
-- 效果②分支二的目标检查与设定：检查自己场上是否有空怪兽区域、卡组中是否有能特殊召唤的念动力族以外的「征服斗魂」怪兽，并确认同一连锁未发动过此效果
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上的怪兽区域是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的念动力族以外的「征服斗魂」怪兽，且该连锁未曾发动过本卡的效果
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册本卡片ID的Flag，用于防止同一连锁内重复发动该卡的效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置连锁处理的操作信息：包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②分支二的执行：从卡组将1只念动力族以外的「征服斗魂」怪兽特殊召唤
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否没有空位，若没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中1张满足特殊召唤条件的念动力族以外的「征服斗魂」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
