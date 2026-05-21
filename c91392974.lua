--出幻
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的表侧表示的「英雄」怪兽被战斗·效果破坏的场合才能发动。从卡组把1只4星以下的「幻影英雄」怪兽特殊召唤。那之后，可以选对方场上1只怪兽，那个原本的攻击力·守备力变成一半。
function c91392974.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的表侧表示的「英雄」怪兽被战斗·效果破坏的场合才能发动。从卡组把1只4星以下的「幻影英雄」怪兽特殊召唤。那之后，可以选对方场上1只怪兽，那个原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91392974,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+91392974)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,91392974+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c91392974.condition)
	e1:SetTarget(c91392974.target)
	e1:SetOperation(c91392974.operation)
	c:RegisterEffect(e1)
	if not c91392974.global_check then
		c91392974.global_check=true
		-- ①：自己场上的表侧表示的「英雄」怪兽被战斗·效果破坏的场合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c91392974.regcon)
		ge1:SetOperation(c91392974.regop)
		-- 注册全局环境效果，用于在后台监听场上卡片的破坏事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤条件：自己场上表侧表示的「英雄」怪兽因战斗或效果被破坏
function c91392974.cfilter(c,tp)
	return c:IsPreviousSetCard(0x8) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查是否有满足条件的怪兽被破坏，并记录被破坏怪兽的控制者
function c91392974.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c91392974.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c91392974.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，将破坏信息传递给发动的效果
function c91392974.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 抛出自定义事件，通知系统有「英雄」怪兽被破坏并传递受影响的玩家信息
	Duel.RaiseEvent(eg,EVENT_CUSTOM+91392974,re,r,rp,ep,e:GetLabel())
end
-- 效果发动条件：检查触发自定义事件的玩家是否为自己
function c91392974.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 过滤条件：卡组中可以特殊召唤的4星以下「幻影英雄」怪兽
function c91392974.filter(c,e,tp)
	return c:IsSetCard(0x5008) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查
function c91392974.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的4星以下「幻影英雄」怪兽
		and Duel.IsExistingMatchingCard(c91392974.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：攻击力或守备力不为0的表侧表示怪兽
function c91392974.atkfilter(c)
	-- 检查怪兽是否为表侧表示且攻击力或守备力大于0
	return aux.nzatk(c) or aux.nzdef(c)
end
-- 效果处理的核心逻辑：特殊召唤怪兽，并可选地将对方怪兽的原本攻防减半
function c91392974.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「幻影英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c91392974.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤，并检查是否特殊召唤成功
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查对方场上是否存在攻击力或守备力不为0的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c91392974.atkfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择发动后续的攻防减半效果
		and Duel.SelectYesNo(tp,aux.Stringid(91392974,1)) then  --"是否选怪兽攻击力·守备力减半？"
		-- 提示玩家选择1只表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择对方场上1只表侧表示且攻防不为0的怪兽
		local g2=Duel.SelectMatchingCard(tp,c91392974.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 中断当前效果处理，使后续的攻防减半效果不与特殊召唤同时处理
		Duel.BreakEffect()
		-- 为选中的怪兽显示选择动画
		Duel.HintSelection(g2)
		local tc=g2:GetFirst()
		local batk=tc:GetBaseAttack()
		local bdef=tc:GetBaseDefense()
		-- 那个原本的攻击力·守备力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(math.ceil(bdef/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
