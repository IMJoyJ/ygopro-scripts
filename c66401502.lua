--VS パンテラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●地：这个回合，这张卡不会被战斗破坏。
-- ●地·炎：和这张卡相同纵列的魔法·陷阱卡全部破坏。
function c66401502.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。①：自己的主要怪兽区域没有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地：这个回合，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66401502,1))  --"展示地属性的怪兽"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66401503)
	e2:SetCost(c66401502.indescost)
	-- 限制效果只能在自己或对方的战斗阶段（或者有战斗阶段的时点）发动
	e2:SetCondition(aux.bpcon)
	e2:SetTarget(c66401502.indestg)
	e2:SetOperation(c66401502.indesop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地·炎：和这张卡相同纵列的魔法·陷阱卡全部破坏。
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
-- 过滤主要怪兽区域的怪兽（格子号小于5）
function c66401502.spcfilter(c)
	return c:GetSequence()<5
end
-- 检查自己主要怪兽区域是否没有怪兽存在
function c66401502.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤并判断自己场上主要怪兽区域是否存在怪兽，若不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(c66401502.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶点与可行性判定：检查自己怪兽区域是否有空位、此卡是否可以特殊召唤，并且连锁中未发动过同名效果
function c66401502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk为0时，检查自己主要怪兽区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查当前连锁中是否未发动过同名效果（限制同一连锁只能发动一次）
		and Duel.GetFlagEffect(tp,66401502)==0 end
	-- 给玩家注册同名效果的Flag标记（连锁结束时重置），用于限制同一连锁不能重复发动
	Duel.RegisterFlagEffect(tp,66401502,RESET_CHAIN,0,1)
	-- 设置效果处理的操作信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理：若此卡仍与连锁相关，则在场上特殊召唤
function c66401502.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手牌中未给对方观看（未公开）的地属性怪兽
function c66401502.indescfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsPublic()
end
-- 展示地属性怪兽的发动代价：确认手牌是否有符合的地属性怪兽，选择并给对方确认，最后洗手卡
function c66401502.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查手牌中是否存在至少1只未展示的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66401502.indescfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择给对方确认（观看）的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择1只未公开的手卡地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c66401502.indescfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认所选择的怪兽卡
	Duel.ConfirmCards(1-tp,g)
	-- 若此卡属于「征服斗魂」系列，则触发观看卡片的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
end
-- 战破抗性效果的发动靶点与限制判定：检查同一连锁上是否未发动过同名效果，并注册同一连锁发动标记
function c66401502.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查当前连锁中是否尚未发动过同名效果
	if chk==0 then return Duel.GetFlagEffect(tp,66401502)==0 end
	-- 注册限制同一连锁发动的标记，连锁结束时重置
	Duel.RegisterFlagEffect(tp,66401502,RESET_CHAIN,0,1)
end
-- 战破抗性效果的处理：若此卡在场，本回合内赋予其不会被战斗破坏的效果
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
-- 过滤手牌中未公开的地属性或炎属性怪兽
function c66401502.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 破坏纵列魔陷效果的发动代价：确认手牌是否可凑齐地与炎属性怪兽各1只，选择并给对方确认，最后洗手卡
function c66401502.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌中所有未公开的地属性和炎属性怪兽
	local g=Duel.GetMatchingGroup(c66401502.descfilter,tp,LOCATION_HAND,0,nil)
	-- 在chk为0时，检查是否能从手牌中选出符合条件的地属性和炎属性怪兽各1只
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE) end
	-- 提示玩家选择给对方确认（观看）的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择地属性和炎属性的怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE)
	-- 将选择的2张怪兽卡给对方玩家确认
	Duel.ConfirmCards(1-tp,sg)
	-- 若此卡属于「征服斗魂」系列，则触发观看卡片的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
end
-- 破坏纵列魔陷效果的发动靶点与限制判定：获取相同纵列的魔陷，检查是否存在可破坏的卡并注册限发标记，最后设置破坏操作信息
function c66401502.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetColumnGroup():Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)
	-- 在chk为0时，判断相同纵列是否存在魔法·陷阱卡，并检查同一连锁中是否未发动过同名效果
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,66401502)==0 end
	-- 注册限制同一连锁发动的标记，连锁结束时重置
	Duel.RegisterFlagEffect(tp,66401502,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息：破坏查找到的全部相同纵列魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的处理：若此卡仍在场，获取其相同纵列的所有魔法·陷阱卡并将其破坏
function c66401502.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=c:GetColumnGroup():Filter(Card.IsType,nil,TYPE_SPELL+TYPE_TRAP)
	-- 将相同纵列的魔法·陷阱卡因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
