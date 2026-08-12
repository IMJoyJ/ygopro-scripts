--VS 蛟龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己为让「征服斗魂」卡的效果发动而把手卡给人观看的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●炎：场上1只怪兽的表示形式变更。
-- ●炎·炎：从卡组把「征服斗魂 蛟龙」以外的1张「征服斗魂」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：包括①效果手卡被展示时从手牌特殊召唤，以及②效果根据展示的炎属性怪兽数量发动的两个分支（变更怪兽表示形式、检索「征服斗魂」卡）
function s.initial_effect(c)
	-- ①：自己为让「征服斗魂」卡的效果发动而把手卡给人观看的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●炎：场上1只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"展示1只炎属性的怪兽"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabel(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))  --"展示2只炎属性的怪兽"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetLabel(2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 检查触发事件的卡片是否是作为自己「征服斗魂」卡效果的发动Cost而展示的手牌怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and r&REASON_COST>0 and re:IsActivated()
		and re:GetHandler():IsSetCard(0x195) and rp==tp
end
-- 特殊召唤效果的发动条件检查：验证己方怪兽区有空位、这张卡可特殊召唤且当前连锁中该卡效果未发动过
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空闲的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查当前连锁中是否未发动过该卡的效果（同一连锁上不能发动）
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 注册当前连锁有效的Flag，用于限制在同一连锁中该卡的效果只能发动一次
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息：包含特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理：若这张卡仍在手牌中，则将其表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出自己手牌中未公开的炎属性怪兽，用作展示Cost
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 效果发动Cost的处理：展示手牌中对应数量的炎属性怪兽，并触发手牌被展示的自定义事件，最后洗切手牌
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查自己手牌中是否存在指定数量未公开的炎属性怪兽用于作为发动Cost
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,ct,nil) end
	-- 提示玩家选择给对方确认的手牌卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌选择指定数量满足条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,ct,ct,nil)
	-- 将选中的手牌给对方确认展示
	Duel.ConfirmCards(1-tp,g)
	-- 若此效果来源为「征服斗魂」卡，则以Cost原因触发自定义展示事件以供其他卡片诱发（如该卡的①效果）
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+id,e,REASON_COST,tp,tp,0) end
	-- 重新洗切玩家的手牌
	Duel.ShuffleHand(tp)
end
-- 表示形式变更分支效果的发动条件检查：验证场上是否存在能变更表示形式的怪兽，注册Flag并设置操作信息
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以变更表示形式的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查场上是否存在可以变更表示形式的怪兽，且当前连锁中该卡效果未发动过
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,id)==0 end
	-- 注册当前连锁有效的Flag，用于限制在同一连锁中该卡的效果只能发动一次
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息：包含变更场上1只怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 表示形式变更分支效果的处理：选择场上1只怪兽并变更其表示形式
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要变更表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只可以变更表示形式的怪兽
	local tc=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		-- 改变目标怪兽的表示形式（表侧守备、里侧守备或表侧攻击）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 过滤出卡组中除「征服斗魂 蛟龙」以外的「征服斗魂」卡片
function s.filter(c)
	return c:IsSetCard(0x195) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 检索分支效果的发动条件检查：验证卡组中是否存在可检索的卡片，且当前连锁中该卡效果未发动过
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「征服斗魂」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查当前连锁中是否未发动过该卡的效果（同一连锁上不能发动）
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 注册当前连锁有效的Flag，用于限制在同一连锁中该卡的效果只能发动一次
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置连锁的操作信息：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索分支效果的处理：从卡组将除「征服斗魂 蛟龙」以外的1张「征服斗魂」卡加入手牌并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择除「征服斗魂 蛟龙」以外的1张「征服斗魂」卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
