--VS パンテラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●地：这个回合，这张卡不会被战斗破坏。
-- ●地·炎：和这张卡相同纵列的魔法·陷阱卡全部破坏。
function c66401502.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66401502,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,66401502)
	e1:SetCondition(c66401502.spcon)
	e1:SetTarget(c66401502.sptg)
	e1:SetOperation(c66401502.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地：这个回合，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66401502,1))  --"展示地属性的怪兽"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66401503)
	e2:SetCost(c66401502.indescost)
	-- 设置效果的发动条件为：当前处于可以进行战斗相关操作的时点或阶段（主要阶段1或战斗阶段）。
	e2:SetCondition(aux.bpcon)
	e2:SetTarget(c66401502.indestg)
	e2:SetOperation(c66401502.indesop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地·炎：和这张卡相同纵列的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66401502,2))  --"展示地·炎属性的怪兽"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,66401503)
	e3:SetHintTiming(0,TIMING_EQUIP+TIMING_END_PHASE)
	e3:SetCost(c66401502.descost)
	e3:SetTarget(c66401502.destg)
	e3:SetOperation(c66401502.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：过滤出处于主要怪兽区域（格子编号0-4）的怪兽。
function c66401502.spcfilter(c)
	return c:GetSequence()<5
end
-- 效果1（特殊召唤）的发动条件：自己的主要怪兽区域没有怪兽存在。
function c66401502.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区域（不含额外怪兽区域）是否不存在任何怪兽。
	return not Duel.IsExistingMatchingCard(c66401502.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果1（特殊召唤）的发动准备与合法性检测。
function c66401502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查当前连锁中是否尚未发动过该卡的效果（用于落实同一连锁上不能发动的限制）。
		and Duel.GetFlagEffect(tp,66401502)==0 end
	-- 在当前连锁中为玩家注册已发动该卡效果的标记，连锁结束时重置，用于防止同一连锁重复发动。
	Duel.RegisterFlagEffect(tp,66401502,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果1（特殊召唤）的效果处理：若自身仍在手卡，则将其特殊召唤。
function c66401502.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：过滤出自己手卡中未公开的地属性怪兽。
function c66401502.indescfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsPublic()
end
-- 效果2（地属性选项）的发动代价处理：展示手卡中的1只地属性怪兽。
function c66401502.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少1只未公开的地属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c66401502.indescfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认（展示）的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡选择1只满足条件的地属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c66401502.indescfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽给对方玩家确认（展示）。
	Duel.ConfirmCards(1-tp,g)
	-- 触发展示手卡怪兽的自定义事件（用于与其他“征服斗魂”卡片的效果联动）。
	Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 重新洗切玩家的手卡。
	Duel.ShuffleHand(tp)
end
-- 效果2（地属性选项）的发动准备与同一连锁发动限制检测。
function c66401502.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前连锁中是否尚未发动过该卡的效果。
	if chk==0 then return Duel.GetFlagEffect(tp,66401502)==0 end
	-- 在当前连锁中为玩家注册已发动该卡效果的标记，连锁结束时重置。
	Duel.RegisterFlagEffect(tp,66401502,RESET_CHAIN,0,1)
end
-- 效果2（地属性选项）的效果处理：为自身施加本回合不会被战斗破坏的持续效果。
function c66401502.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- ●地：这个回合，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	c:RegisterEffect(e1)
end
-- 过滤函数：过滤出自己手卡中未公开的地属性或炎属性怪兽。
function c66401502.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 效果2（地·炎属性选项）的发动代价处理：展示手卡中的地属性和炎属性怪兽各1只。
function c66401502.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡中所有未公开的地属性或炎属性怪兽。
	local g=Duel.GetMatchingGroup(c66401502.descfilter,tp,LOCATION_HAND,0,nil)
	-- 检查手卡中是否能选出地属性和炎属性怪兽各1只（共2张卡）的组合。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE) end
	-- 提示玩家选择要给对方确认（展示）的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡中选择地属性和炎属性怪兽各1只（共2张卡）。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE)
	-- 将选中的2张怪兽给对方玩家确认（展示）。
	Duel.ConfirmCards(1-tp,sg)
	-- 触发展示手卡怪兽的自定义事件。
	Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0)
	-- 重新洗切玩家的手卡。
	Duel.ShuffleHand(tp)
end
-- 效果2（地·炎属性选项）的发动准备：检测相同纵列是否存在魔法·陷阱卡，并设置破坏操作信息。
function c66401502.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetColumnGroup():Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)
	-- 检查与这张卡相同纵列的区域是否存在魔法·陷阱卡，且当前连锁中尚未发动过该卡的效果。
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,66401502)==0 end
	-- 在当前连锁中为玩家注册已发动该卡效果的标记，连锁结束时重置。
	Duel.RegisterFlagEffect(tp,66401502,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息，表明此效果包含破坏相同纵列所有魔法·陷阱卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果2（地·炎属性选项）的效果处理：破坏与这张卡相同纵列的所有魔法·陷阱卡。
function c66401502.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=c:GetColumnGroup():Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)
	-- 将相同纵列的魔法·陷阱卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
