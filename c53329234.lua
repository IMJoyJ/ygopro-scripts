--微睡の罪宝－モーリアン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1只特殊召唤的表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：这张卡在墓地存在，自己场上有5星以上的幻想魔族怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册此卡作为魔法卡发动时改变怪兽表示形式的效果，以及在墓地存在时可以盖放到场上的起动效果
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
-- 过滤场上特殊召唤上场且处于表侧表示、能变成里侧守备表示的怪兽
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsFaceup() and c:IsCanTurnSet()
end
-- 魔法卡发动效果的目标判定与注册：判定并选择场上1只符合条件的特殊召唤的表侧表示怪兽为效果对象，并注册改变表示形式的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 判断场上是否存在至少1只可成为效果对象的特殊召唤的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 在界面上提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家在场上选择1只满足条件的表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 注册将选中的怪兽改变表示形式的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：若选中的对象怪兽仍合法存在于场上，则将其变成里侧守备表示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果所选中的唯一对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将选中的对象怪兽的表示形式变更为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤自己场上表侧表示的5星以上幻想魔族怪兽
function s.setfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5) and c:IsFaceup()
end
-- 判定发动条件：自己场上是否存在5星以上的幻想魔族怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少1只表侧表示的5星以上的幻想魔族怪兽
	return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判定发动目标：检测墓地中的此卡是否可以在场上盖放，并注册涉及离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 注册将墓地中的此卡移动（离开墓地）的效果分类和操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡在墓地中状态合法，则在自己场上盖放，并为其注册“从场上离开的场合除外”的重定向效果
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡因该效果成功在自己场上盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
