--リンク・デス・ターレット
-- 效果：
-- ①：作为这张卡的发动时的效果处理，给这张卡放置4个指示物。
-- ②：每次自己受到战斗伤害给这张卡放置1个指示物。
-- ③：自己主要阶段2，把这张卡1个指示物取除，以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。这个效果发动的回合，自己不是暗属性连接怪兽不能从额外卡组特殊召唤。
function c55034079.initial_effect(c)
	c:EnableCounterPermit(0x48)
	-- ①：作为这张卡的发动时的效果处理，给这张卡放置4个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c55034079.target)
	e1:SetOperation(c55034079.activate)
	c:RegisterEffect(e1)
	-- ②：每次自己受到战斗伤害给这张卡放置1个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c55034079.ctcon)
	e2:SetOperation(c55034079.ctop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段2，把这张卡1个指示物取除，以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，从场上离开的场合除外。这个效果发动的回合，自己不是暗属性连接怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c55034079.spcon)
	e3:SetCost(c55034079.spcost)
	e3:SetTarget(c55034079.sptg)
	e3:SetOperation(c55034079.spop)
	c:RegisterEffect(e3)
	-- 注册一个自定义活动计数器，用于检测本回合玩家从额外卡组特殊召唤非暗属性连接怪兽的次数。
	Duel.AddCustomActivityCounter(55034079,ACTIVITY_SPSUMMON,c55034079.counterfilter)
end
-- 魔法卡发动时的效果处理（Target阶段），确认是否能给这张卡放置4个指示物。
function c55034079.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查是否能向这张卡放置4个指示物。
	if chk==0 then return Duel.IsCanAddCounter(tp,0x48,4,c) end
end
-- 魔法卡发动时的效果处理（Operation阶段），给这张卡放置4个指示物。
function c55034079.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x48,4)
	end
end
-- 过滤函数，判定卡片是否不是从额外卡组特殊召唤，或者是暗属性连接怪兽。
function c55034079.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup())
end
-- 检查受到伤害的玩家是否为自己，且伤害原因为战斗伤害。
function c55034079.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE)==REASON_BATTLE
end
-- 给这张卡放置1个指示物。
function c55034079.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x48,1)
end
-- 检查当前是否为自己的主要阶段2。
function c55034079.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己，且当前阶段是否为主要阶段2。
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果发动的Cost，检查是否能取除1个指示物，且本回合至今没有从额外卡组特殊召唤过非暗属性连接怪兽。
function c55034079.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x48,1,REASON_EFFECT)
		-- 检查本回合至今玩家是否没有进行过不符合条件的特殊召唤（即没有从额外卡组特殊召唤过非暗属性连接怪兽）。
		and Duel.GetCustomActivityCount(55034079,tp,ACTIVITY_SPSUMMON)==0 end
	c:RemoveCounter(tp,0x48,1,REASON_EFFECT)
	-- 以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果发动的回合，自己不是暗属性连接怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c55034079.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家本回合不能从额外卡组特殊召唤暗属性连接怪兽以外的怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止从额外卡组特殊召唤非暗属性连接怪兽。
function c55034079.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤自己墓地可以特殊召唤的「弹丸」怪兽。
function c55034079.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的Target阶段，检查怪兽区域空位并选择墓地1只「弹丸」怪兽作为对象。
function c55034079.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55034079.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「弹丸」怪兽。
		and Duel.IsExistingTarget(c55034079.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只「弹丸」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c55034079.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理的操作信息为特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的Operation阶段，将对象怪兽特殊召唤，并适用效果无效化和离场除外的限制。
function c55034079.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，并判断是否特殊召唤成功。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e2,true)
		-- 从场上离开的场合除外
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e3,true)
	end
end
