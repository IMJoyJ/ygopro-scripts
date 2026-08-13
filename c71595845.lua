--人形の幸福
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「德梅特爷爷」或者「玩具盒」加入手卡。
-- ②：只要自己场上有「珂珑公主」存在，对方不能选择攻击力或守备力是0的怪兽作为攻击对象。
-- ③：1回合1次，可以发动。选自己的手卡·场上1只怪兽破坏，从卡组把1张「人偶怪兽」卡送去墓地。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
function c71595845.initial_effect(c)
	-- 记录这张卡上记载着「德梅特爷爷」「玩具盒」「珂珑公主」的卡名
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
-- 过滤函数：筛选卡名为「德梅特爷爷」或「玩具盒」且可以加入手卡的卡
function c71595845.filter(c)
	return c:IsCode(44190146,81587028) and c:IsAbleToHand()
end
-- 发动时的目标处理：检查卡组是否存在可加入手卡的符合条件的卡，并设置检索操作信息
function c71595845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的成立条件：确认自己卡组存在至少1只可以加入手卡的「德梅特爷爷」或「玩具盒」
	if chk==0 then return Duel.IsExistingMatchingCard(c71595845.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告将从卡组把1张卡加入手卡（用于其他卡的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从卡组选择1只「德梅特爷爷」或「玩具盒」加入手卡，并向对方展示确认
function c71595845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只「德梅特爷爷」或「玩具盒」
	local g=Duel.SelectMatchingCard(tp,c71595845.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选中的卡以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡出示给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选自己场上表侧表示的「珂珑公主」
function c71595845.atkfilter(c)
	return c:IsCode(75574498) and c:IsFaceup()
end
-- ②效果的适用条件：自己场上存在表侧表示的「珂珑公主」
function c71595845.atkcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「珂珑公主」
	return Duel.IsExistingMatchingCard(c71595845.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 攻击对象限制判定：表侧表示且攻击力或守备力是0的怪兽不能被对方选择为攻击对象
function c71595845.atkval(e,c)
	return c:IsFaceup() and (c:IsAttack(0) or c:IsDefense(0))
end
-- 过滤函数：筛选可以送去墓地的「人偶怪兽」卡
function c71595845.tgfilter(c)
	return c:IsAbleToGrave() and c:IsSetCard(0x15a)
end
-- ③效果的目标处理：确认卡组存在可送去墓地的「人偶怪兽」卡且自己手卡·场上存在怪兽，并设置送去墓地和破坏的操作信息
function c71595845.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动的成立条件之一：确认自己卡组存在至少1张可以送去墓地的「人偶怪兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71595845.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 发动的成立条件之二：确认自己的手卡·场上存在至少1只怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,TYPE_MONSTER) end
	-- 设置操作信息：宣告将从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：宣告将破坏自己手卡·场上的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ③效果的处理：选自己手卡·场上1只怪兽破坏，破坏成功后从卡组把1张「人偶怪兽」卡送去墓地，然后对自己适用这个回合不能从额外卡组特殊召唤超量怪兽以外的怪兽的限制
function c71595845.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手卡·场上选择1只要破坏的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 以效果原因破坏选中的怪兽，破坏成功时继续后续处理
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 向玩家提示「请选择要送去墓地的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从自己卡组选择1张要送去墓地的「人偶怪兽」卡
		g=Duel.SelectMatchingCard(tp,c71595845.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 把选中的卡以效果原因送去墓地
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
	-- 把特殊召唤限制效果注册给自己玩家，直到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的判定：从额外卡组特殊召唤的怪兽不是超量怪兽的场合不能特殊召唤
function c71595845.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
