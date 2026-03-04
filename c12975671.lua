--ファースト・ペンギン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有表侧表示怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
-- ②：丢弃1张手卡，把额外卡组1只水属性同调怪兽给对方观看才能发动。比给人观看的怪兽等级低1星并种族相同的1只水属性怪兽从卡组加入手卡。那之后，可以把这张卡变成里侧守备表示。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：自己场上没有表侧表示怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.sprcon)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡，把额外卡组1只水属性同调怪兽给对方观看才能发动。比给人观看的怪兽等级低1星并种族相同的1只水属性怪兽从卡组加入手卡。那之后，可以把这张卡变成里侧守备表示。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 判断特殊召唤条件是否满足
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否没有表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 执行特殊召唤操作
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 特殊召唤时将此卡变为调整
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
end
-- 发动效果时的费用处理
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足额外卡组有水属性同调怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		-- 检查是否满足丢弃一张手卡的条件
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 获取满足条件的额外卡组水属性同调怪兽
	local exg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)
	-- 丢弃一张手卡作为费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 提示选择要确认的额外卡组怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=exg:Select(tp,1,1,nil):GetFirst()
	-- 向对方确认所选的额外卡组怪兽
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabel(tc:GetLevel()-1,tc:GetRace())
end
-- 筛选可加入手卡的水属性怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(2)
		-- 检查卡组中是否存在满足等级和种族条件的水属性怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel()-1,c:GetRace())
end
-- 筛选满足等级和种族条件的水属性怪兽
function s.thfilter(c,level,race)
	return c:IsLevel(level) and c:IsRace(race) and c:IsType(TYPE_MONSTER)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 设置效果发动时的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置效果处理时要加入手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv,race=e:GetLabel()
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡加入手卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv,race)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsLocation(LOCATION_HAND) and c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
			-- 判断是否选择将此卡变为里侧守备表示
			and c:IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将此卡变为里侧守备表示
			Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
		end
	end
	-- 设置本回合不能从额外卡组特殊召唤非水属性怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判断函数
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
