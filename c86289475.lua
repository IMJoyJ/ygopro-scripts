--磁石の戦士Ω＋
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只岩石族怪兽破坏，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：场上的地属性怪兽的效果发动时，把这张卡解放，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡/墓地特召）和②效果（地属性怪兽效果发动时解放自身使场上怪兽变里侧）。
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只岩石族怪兽破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的地属性怪兽的效果发动时，把这张卡解放，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.poscon)
	e2:SetCost(s.poscost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
-- 过滤可破坏的岩石族怪兽的条件函数（表侧表示、岩石族，且破坏后能空出怪兽区域供特殊召唤）。
function s.desfilter(c,tp)
	-- 判定卡片是否为表侧表示（手卡视为表侧）的岩石族怪兽，且该卡离开场上后能空出至少1个怪兽区域。
	return c:IsFaceupEx() and c:IsRace(RACE_ROCK) and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的发动准备（Target）函数，检查是否存在可破坏的岩石族怪兽以及自身能否特殊召唤，并设置破坏与特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己手卡·场上（表侧表示）除这张卡以外满足条件的岩石族怪兽组。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c,tp)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：破坏1张满足条件的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息为：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理（Operation）函数，选择并破坏1只岩石族怪兽，将这张卡特殊召唤，并添加离场除外的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从手卡·场上选择1只满足条件的岩石族怪兽（排除自身）。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		-- 选中场上的怪兽时，在场上显示被选中的动画效果。
		Duel.HintSelection(g)
	end
	-- 成功破坏选中的怪兽，且这张卡仍与连锁有关联，并且不受王家之谷影响。
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将这张卡以表侧表示特殊召唤成功。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。场上的地属性怪兽的效果发动时，把这张卡解放，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件（Condition）函数，判定是否为场上的地属性怪兽发动效果。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的卡片的发动位置和属性。
	local loc,attr=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTRIBUTE)
	return re:IsActiveType(TYPE_MONSTER)
		and (attr&ATTRIBUTE_EARTH)~=0
		and (loc&LOCATION_ONFIELD)~=0
end
-- ②效果的发动代价（Cost）处理函数，检查并执行解放自身的操作。
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤可变为里侧守备表示的怪兽的条件函数（场上表侧表示且可以变成里侧表示）。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的发动准备（Target）函数，选择场上1只表侧表示怪兽作为对象，并设置改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 判定场上是否存在可以变成里侧守备表示的表侧表示怪兽（排除自身）。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：改变目标怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的效果处理（Operation）函数，将作为对象的怪兽变成里侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽变成里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
