--魔轟神トピー
-- 效果：
-- ①：自己手卡比对方少2张以上的场合，把手卡1只「魔轰神」怪兽给对方观看，把这张卡解放，以对方场上2张魔法·陷阱卡为对象才能发动。那些对方的卡破坏。
function c46833854.initial_effect(c)
	-- 效果原文：①：自己手卡比对方少2张以上的场合，把手卡1只「魔轰神」怪兽给对方观看，把这张卡解放，以对方场上2张魔法·陷阱卡为对象才能发动。那些对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46833854,0))  --"对方场上存在的2张魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c46833854.con)
	e1:SetCost(c46833854.cost)
	e1:SetTarget(c46833854.tg)
	e1:SetOperation(c46833854.op)
	c:RegisterEffect(e1)
end
-- 规则层面：检查自己手卡数量是否比对方少至少2张
function c46833854.con(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：计算自己手卡数量减去对方手卡数量是否大于等于2
	return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2
end
-- 规则层面：定义过滤函数，用于筛选手牌中未公开的「魔轰神」怪兽
function c46833854.cfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 规则层面：设置效果发动的费用，需要解放自身并从手牌中选择一只未公开的「魔轰神」怪兽
function c46833854.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 规则层面：检查手牌中是否存在至少1只满足条件的「魔轰神」怪兽
		and Duel.IsExistingMatchingCard(c46833854.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 规则层面：向玩家提示“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 规则层面：选择一只满足条件的「魔轰神」怪兽
	local g=Duel.SelectMatchingCard(tp,c46833854.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 规则层面：将所选怪兽展示给对方玩家
	Duel.ConfirmCards(1-tp,g)
	-- 规则层面：解放自身作为效果发动的费用
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 规则层面：洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 规则层面：定义过滤函数，用于筛选魔法·陷阱卡
function c46833854.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面：设置效果的目标选择阶段，选择对方场上的2张魔法·陷阱卡
function c46833854.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c46833854.filter(chkc) end
	-- 规则层面：检查对方场上是否存在至少2张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c46833854.filter,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 规则层面：向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面：选择对方场上的2张魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c46833854.filter,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 规则层面：设置效果操作信息，表示将破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 规则层面：执行效果的处理阶段，对选定的目标卡进行破坏
function c46833854.op(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 规则层面：将满足条件的目标卡进行破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
