--死のデッキ破壊ウイルス
-- 效果：
-- ①：把自己场上1只攻击力1000以下的暗属性怪兽解放才能发动。对方场上的怪兽以及对方手卡全部确认，那之内的攻击力1500以上的怪兽全部破坏。那之后，对方可以从卡组选最多3只攻击力1500以上的怪兽破坏。这张卡的发动后，直到下个回合的结束时对方受到的全部伤害变成0。
function c57728570.initial_effect(c)
	-- ①：把自己场上1只攻击力1000以下的暗属性怪兽解放才能发动。对方场上的怪兽以及对方手卡全部确认，那之内的攻击力1500以上的怪兽全部破坏。那之后，对方可以从卡组选最多3只攻击力1500以上的怪兽破坏。这张卡的发动后，直到下个回合的结束时对方受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCost(c57728570.cost)
	e1:SetTarget(c57728570.target)
	e1:SetOperation(c57728570.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上攻击力1000以下的暗属性怪兽
function c57728570.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackBelow(1000)
end
-- 发动代价处理：解放自己场上1只满足过滤条件的怪兽
function c57728570.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的满足过滤条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c57728570.costfilter,1,nil) end
	-- 让玩家选择1只满足过滤条件的怪兽用于解放
	local g=Duel.SelectReleaseGroup(tp,c57728570.costfilter,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：攻击力1500以上的怪兽
function c57728570.filter(c)
	return c:IsAttackAbove(1500)
end
-- 过滤条件：未确认的手卡，或者攻击力1500以上的怪兽
function c57728570.hgfilter(c)
	return not c:IsPublic() or c57728570.filter(c)
end
-- 过滤条件：里侧表示的怪兽，或者攻击力1500以上的怪兽
function c57728570.fgfilter(c)
	return c:IsFacedown() or c57728570.filter(c)
end
-- 过滤条件：已确认的对方手卡或对方场上表侧表示的攻击力1500以上的怪兽
function c57728570.tgfilter(c)
	return ((c:IsLocation(LOCATION_HAND) and c:IsPublic()) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) and c57728570.filter(c)
end
-- 效果发动时的目标选择与检测处理
function c57728570.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在未确认的卡或攻击力1500以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57728570.hgfilter,tp,0,LOCATION_HAND,1,nil)
		-- 或者检查对方场上是否存在里侧表示的怪兽或攻击力1500以上的怪兽
		or Duel.IsExistingMatchingCard(c57728570.fgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上和手卡中已知的攻击力1500以上的怪兽
	local g=Duel.GetMatchingGroup(c57728570.tgfilter,tp,0,LOCATION_MZONE+LOCATION_HAND,nil)
	-- 设置效果处理的破坏操作信息，包含预估破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理的核心逻辑
function c57728570.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上和手卡的所有卡片
	local conf=Duel.GetFieldGroup(tp,0,LOCATION_MZONE+LOCATION_HAND)
	local ct=0
	if conf:GetCount()>0 then
		-- 让己方玩家确认对方场上和手卡的所有卡片
		Duel.ConfirmCards(tp,conf)
		local dg=conf:Filter(c57728570.filter,nil)
		-- 破坏其中所有攻击力1500以上的怪兽，并记录破坏的数量
		ct=Duel.Destroy(dg,REASON_EFFECT)
		-- 重新洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
	-- 获取对方卡组中所有攻击力1500以上的怪兽
	local g=Duel.GetMatchingGroup(c57728570.filter,1-tp,LOCATION_DECK,0,nil)
	-- 若有卡被破坏且对方卡组有符合条件的怪兽，询问对方是否从卡组选择怪兽破坏
	if ct>0 and g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(57728570,0)) then  --"是否把卡组的怪兽破坏？"
		-- 中断当前效果处理，使后续的破坏处理不与前面的破坏同时进行
		Duel.BreakEffect()
		-- 给对方玩家发送选择破坏卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(1-tp,1,3,nil)
		-- 破坏对方从卡组中选出的怪兽
		Duel.Destroy(dg,REASON_EFFECT)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时对方受到的全部伤害变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册使对方受到的战斗伤害变成0的全局效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册使对方受到的效果伤害变成0的全局效果
		Duel.RegisterEffect(e2,tp)
	end
end
