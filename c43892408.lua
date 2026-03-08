--竜騎士ブラック・マジシャン・ガール
-- 效果：
-- 「黑魔术少女」＋龙族怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤以及用「蒂迈欧之眼」的效果才能特殊召唤。
-- ①：自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
function c43892408.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为38033121的「黑魔术少女」和1只龙族怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,38033121,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),1,false,false)
	-- ①：自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c43892408.splimit)
	c:RegisterEffect(e1)
	-- ①：自己·对方回合1次，把1张手卡送去墓地，以场上1张表侧表示卡为对象才能发动。那张表侧表示卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43892408,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c43892408.cost)
	e2:SetTarget(c43892408.target)
	e2:SetOperation(c43892408.activate)
	c:RegisterEffect(e2)
end
-- 该效果仅在融合召唤或使用「蒂迈欧之眼」的效果时才能特殊召唤
function c43892408.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or se:GetHandler():IsCode(1784686)
end
-- 支付1张手卡送去墓地的代价
function c43892408.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 将1张手卡送去墓地作为代价
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤函数，用于判断目标卡是否为表侧表示
function c43892408.filter(c)
	return c:IsFaceup()
end
-- 设置效果目标，选择场上1张表侧表示卡
function c43892408.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c43892408.filter(chkc) end
	-- 检查场上是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c43892408.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,c43892408.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果，破坏选择的卡
function c43892408.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因破坏对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
