--人形の幸福
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「德梅特爷爷」或者「玩具盒」加入手卡。
-- ②：只要自己场上有「珂珑公主」存在，对方不能选择攻击力或守备力是0的怪兽作为攻击对象。
-- ③：1回合1次，可以发动。选自己的手卡·场上1只怪兽破坏，从卡组把1张「人偶怪兽」卡送去墓地。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
function c71595845.initial_effect(c)
	-- 注册该卡记述了「德梅特爷爷」、「玩具盒」以及「珂珑公主」的卡片密码。
	aux.AddCodeList(c,44190146,81587028,75574498)
	-- ①：作为这张卡的发动时的效果处理，从卡组把1只「德梅特爷爷」或者「玩具盒」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,71595845+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c71595845.target)
	e1:SetOperation(c71595845.activate)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「珂珑公主」存在，对方不能选择攻击力或守备力是0的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c71595845.atkcon)
	e2:SetValue(c71595845.atkval)
	c:RegisterEffect(e2)
	-- ③：1回合1次，可以发动。选自己的手卡·场上1只怪兽破坏，从卡组把1张「人偶怪兽」卡送去墓地。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c71595845.tgtg)
	e3:SetOperation(c71595845.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为「德梅特爷爷」或「玩具盒」且能加入手卡。
function c71595845.filter(c)
	return c:IsCode(44190146,81587028) and c:IsAbleToHand()
end
-- ①号效果（发动时的效果处理）的靶向/发动条件检测与操作信息设置函数。
function c71595845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查卡组中是否存在至少1张满足过滤条件的卡（「德梅特爷爷」或「玩具盒」）。
	if chk==0 then return Duel.IsExistingMatchingCard(c71595845.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：往连锁中注册“从卡组将1张卡加入手卡”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果（发动时的效果处理）的执行函数。
function c71595845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡（「德梅特爷爷」或「玩具盒」）。
	local g=Duel.SelectMatchingCard(tp,c71595845.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 因效果将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检查卡片是否为表侧表示的「珂珑公主」。
function c71595845.atkfilter(c)
	return c:IsCode(75574498) and c:IsFaceup()
end
-- ②号效果的适用条件函数：检查自己场上是否存在表侧表示的「珂珑公主」。
function c71595845.atkcon(e)
	-- 检查自己场上是否存在至少1张满足过滤条件的卡（表侧表示的「珂珑公主」）。
	return Duel.IsExistingMatchingCard(c71595845.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- ②号效果的限制对象过滤函数：检查怪兽是否为表侧表示且攻击力或守备力为0。
function c71595845.atkval(e,c)
	return c:IsFaceup() and (c:IsAttack(0) or c:IsDefense(0))
end
-- 过滤函数：检查卡片是否为能送去墓地的「人偶怪兽」卡。
function c71595845.tgfilter(c)
	return c:IsAbleToGrave() and c:IsSetCard(0x15a)
end
-- ③号效果的靶向/发动条件检测与操作信息设置函数。
function c71595845.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查卡组中是否存在至少1张能送去墓地的「人偶怪兽」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c71595845.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且检查自己的手卡或场上是否存在至少1只怪兽。
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,TYPE_MONSTER) end
	-- 设置操作信息：往连锁中注册“从卡组将1张卡送去墓地”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：往连锁中注册“破坏自己手卡或场上1张卡”的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ③号效果的执行函数。
function c71595845.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手卡或场上选择1只怪兽。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 因效果破坏选中的怪兽，若破坏成功则执行后续处理。
	if Duel.Destroy(g,REASON_EFFECT) then
		-- 给玩家发送提示信息：请选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组中选择1张满足过滤条件的「人偶怪兽」卡。
		g=Duel.SelectMatchingCard(tp,c71595845.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 因效果将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	-- 这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71595845.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内生效的额外卡组特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤函数：限制非超量怪兽从额外卡组特殊召唤。
function c71595845.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
