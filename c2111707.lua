--XY－ドラゴン・キャノン
-- 效果：
-- 「X-首领加农」＋「Y-龙头」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤。这张卡不能作从墓地的特殊召唤。
-- ①：丢弃1张手卡，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张对方的表侧表示的卡破坏。
function c2111707.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为62651957和65622692的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,62651957,65622692,true,true)
	-- 添加接触融合特殊召唤规则，要求将自己场上的1只怪兽除外作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- ①：丢弃1张手卡，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张对方的表侧表示的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c2111707.splimit)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张对方的表侧表示的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2111707,0))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c2111707.descost)
	e3:SetTarget(c2111707.destg)
	e3:SetOperation(c2111707.desop)
	c:RegisterEffect(e3)
end
-- 限制此卡不能从墓地特殊召唤
function c2111707.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 丢弃1张手卡作为发动代价
function c2111707.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选场上的表侧表示的魔法·陷阱卡
function c2111707.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择逻辑，选择对方场上的1张表侧表示的魔法·陷阱卡
function c2111707.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c2111707.filter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c2111707.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张表侧表示的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c2111707.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定破坏的目标数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标卡破坏
function c2111707.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
