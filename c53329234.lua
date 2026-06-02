--微睡の罪宝－モーリアン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：这张卡在墓地存在，自己场上有5星以上的幻想魔族怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②的效果
function s.initial_effect(c)
	-- ①：以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有5星以上的幻想魔族怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡在场上盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为特殊召唤且表侧表示且可以变为里侧守备表示的怪兽
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup() and c:IsCanTurnSet()
end
-- 处理①效果的目标选择，检查场上是否存在满足条件的怪兽并选择目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查是否有满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，指定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理①效果的发动，将目标怪兽变为里侧守备表示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数，用于判断是否为5星以上幻想魔族且表侧表示的怪兽
function s.setfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5) and c:IsFaceup()
end
-- 处理②效果的发动条件，检查场上是否存在满足条件的幻想魔族怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的幻想魔族怪兽
	return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 处理②效果的目标选择，检查此卡是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，指定将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理②效果的发动，将此卡盖放到场上并设置其离场时的去向
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以盖放且未被无效化
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 设置此卡离场时的去向为除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
