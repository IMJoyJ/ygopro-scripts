--人形の幸福
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「德梅特爷爷」或者「玩具盒」加入手卡。
-- ②：只要自己场上有「珂珑公主」存在，对方不能选择攻击力或守备力是0的怪兽作为攻击对象。
-- ③：1回合1次，可以发动。选自己的手卡·场上1只怪兽破坏，从卡组把1张「人偶怪兽」卡送去墓地。这个回合，自己不是超量怪兽不能从额外卡组特殊召唤。
function c71595845.initial_effect(c)
	-- 记录这张卡上记载着指定卡名卡片的事实
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
-- 过滤卡组中满足条件的「德梅特爷爷」或「玩具盒」并检查其是否能加入手卡
function c71595845.filter(c)
	return c:IsCode(44190146,81587028) and c:IsAbleToHand()
end
-- 效果①的发动准备与操作信息设置
function c71595845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时判断卡组中是否存在满足条件的「德梅特爷爷」或「玩具盒」
	if chk==0 then return Duel.IsExistingMatchingCard(c71595845.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1只「德梅特爷爷」或「玩具盒」加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的生效处理，从卡组把「德梅特爷爷」或「玩具盒」加入手手卡
function c71595845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「德梅特爷爷」或「玩具盒」
	local g=Duel.SelectMatchingCard(tp,c71595845.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认所加入的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示的的「珂珑公主」
function c71595845.atkfilter(c)
	return c:IsCode(75574498) and c:IsFaceup()
end
-- 效果②的启用条件函数，判断自己场上是否存在「珂珑公主」
function c71595845.atkcon(e)
	-- 判断自己场上是否存在表侧表示的「珂珑公主」
	return Duel.IsExistingMatchingCard(c71595845.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 限制对方玩家不能选择攻击力或守备力为0的表侧表示怪兽作为攻击对象
function c71595845.atkval(e,c)
	return c:IsFaceup() and (c:IsAttack(0) or c:IsDefense(0))
end
-- 过滤卡组中的「人偶怪兽」卡
function c71595845.tgfilter(c)
	return c:IsAbleToGrave() and c:IsSetCard(0x15a)
end
-- 效果③的发动准备与操作信息设置
function c71595845.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时判断卡组中是否存在可送墓的「人偶怪兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71595845.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断己方场上或手卡中是否存在怪兽卡
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,TYPE_MONSTER) end
	-- 设置操作信息：将卡组中的「人偶怪兽」卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：破坏自己场上或手卡的一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- 效果③的生效处理，执行破坏己方怪兽、卡组送墓及额外特殊召唤限制的操作
function c71595845.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从己方手卡或场上选择要破坏的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,TYPE_MONSTER)
	-- 破坏选中的怪兽，并判断是否操作成功
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择1张满足条件的「人偶怪兽」卡
		g=Duel.SelectMatchingCard(tp,c71595845.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 以效果原因将选择的卡送去墓地
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
	-- 向玩家注册不能从额外卡组特殊召唤超量怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 判断特殊召唤的目标怪兽是否不是超量怪兽且来自额外卡组
function c71595845.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
