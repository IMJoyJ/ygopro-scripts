--ファースト・ペンギン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有表侧表示怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
-- ②：丢弃1张手卡，把额外卡组1只水属性同调怪兽给对方观看才能发动。比给人观看的怪兽等级低1星并种族相同的1只水属性怪兽从卡组加入手卡。那之后，可以把这张卡变成里侧守备表示。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化函数：创建并注册两个效果——①特殊召唤规则效果（手卡规则特殊召唤，并赋予调整属性）和②起动效果（丢手卡展示额外水属性同调怪兽，检索并可能变里侧守备，附加自肃）。
function s.initial_effect(c)
	-- ①：自己场上没有表侧表示怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.sprcon)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：丢弃1张手卡，把额外卡组1只水属性同调怪兽给对方观看才能发动。比给人观看的怪兽等级低1星并种族相同的1只水属性怪兽从卡组加入手卡。那之后，可以把这张卡变成里侧守备表示。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则条件：自己场上有空余的主要怪兽区，且自己场上不存在表侧表示怪兽。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可用的主要怪兽区空格（用于特殊召唤）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上不存在任何表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤规则的处理：给这只怪兽附加一个不能无效的‘当作调整使用’的效果，该效果在怪兽离场或移动时重置但返回场上不重置。
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
end
-- 发动代价的合法性检查：确认额外卡组存在满足条件的水属性同调怪兽，且手牌存在可丢弃的卡。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在符合条件的展示对象：水属性同调怪兽，且其等级-1、同种族的水属性怪兽能在卡组中找到。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		-- 同时确认手牌中有可以丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 获取额外卡组中所有符合条件的展示对象，作为待选择组。
	local exg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)
	-- 从手牌丢弃1张卡作为发动代价（原因标记为代价+丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 弹出选择提示，要求玩家选择一张要展示给对方确认的卡（提示文字“请选择给对方确认的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc=exg:Select(tp,1,1,nil):GetFirst()
	-- 将选择的额外卡组怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabel(tc:GetLevel()-1,tc:GetRace())
end
-- 定义展示对象的筛选条件：必须是水属性同调怪兽，等级在2以上，并且卡组中存在等级比它低1、种族相同且可检索的水属性怪兽。
function s.cfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(2)
		-- 额外要求卡组中存在满足检索条件的水属性怪兽（等级等于展示怪兽等级-1，种族相同）。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel()-1,c:GetRace())
end
-- 定义检索目标的筛选条件：符合指定的等级和种族，是水属性怪兽且可以被加入手卡。
function s.thfilter(c,level,race)
	return c:IsLevel(level) and c:IsRace(race) and c:IsType(TYPE_MONSTER)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 目标阶段：确认代价已经支付（CostChecked）；然后设置效果处理信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息：本次效果包含从卡组检索1张卡加入手卡（CATEGORY_TOHAND），用于给其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：根据代价阶段储存的等级和种族从卡组选择1只水属性怪兽加入手卡并展示；若检索成功且此卡仍能变成里侧守备表示，则询问玩家是否变成里侧守备；最后给自己附加本回合不能从额外卡组特殊召唤非水属性怪兽的自肃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv,race=e:GetLabel()
	-- 弹出选择提示，要求玩家从卡组选择一张要加入手卡的卡（提示文字“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合筛选条件（指定等级、种族、水属性、可加入手卡）的水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv,race)
	local tc=g:GetFirst()
	if tc then
		-- 将选择到的怪兽加入其持有者的手卡（效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的那只怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsLocation(LOCATION_HAND) and c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
			-- 判断此卡是否能够变成里侧守备表示，并询问玩家是否要变成里侧守备表示；若玩家选择是，则继续处理。
			and c:IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否变成里侧守备表示？"
			-- 中断当前效果处理，使后续的变里侧守备表示作为独立处理（避免错过时点）。
			Duel.BreakEffect()
			-- 将这张卡变成里侧守备表示。
			Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
		end
	end
	-- 这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前玩家（tp），持续到回合结束时重置。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃的判定条件：不允许特殊召唤来自额外卡组的、不是水属性的怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
