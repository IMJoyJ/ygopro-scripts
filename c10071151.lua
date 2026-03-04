--トワイライトロード・ソーサラー ライラ
-- 效果：
-- ①：1回合1次，魔法·陷阱卡的效果发动时，从自己的手卡·墓地把1只「光道」怪兽除外，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：1回合1次，这张卡以外的自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把3张卡送去墓地。
function c10071151.initial_effect(c)
	-- ①：1回合1次，魔法·陷阱卡的效果发动时，从自己的手卡·墓地把1只「光道」怪兽除外，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10071151,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c10071151.descon)
	e1:SetCost(c10071151.descost)
	e1:SetTarget(c10071151.destg)
	e1:SetOperation(c10071151.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡以外的自己的「光道」怪兽的效果发动的场合发动。从自己卡组上面把3张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10071151,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c10071151.ddcon)
	e3:SetTarget(c10071151.ddtg)
	e3:SetOperation(c10071151.ddop)
	c:RegisterEffect(e3)
end
-- 定义效果①的发动条件函数，判定是否为魔法·陷阱卡的效果发动时
function c10071151.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义可作为代价除外的「光道」怪兽的过滤条件（怪兽卡且属于「光道」系列且可以除外作为代价）
function c10071151.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and c:IsAbleToRemoveAsCost()
end
-- 定义效果①的代价处理函数，处理从手卡·墓地除外「光道」怪兽作为代价
function c10071151.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡·墓地是否存在至少1只满足过滤条件的「光道」怪兽可以作为代价除外
	if chk==0 then return Duel.IsExistingMatchingCard(c10071151.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择提示，提示内容为选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 让玩家从自己的手卡·墓地选择1只满足条件的「光道」怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c10071151.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽以表侧表示除外，原因标记为代价（REASON_COST）
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义可作为破坏对象的过滤条件（场上表侧表示的魔法·陷阱卡）
function c10071151.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果①的对象选择函数（取对象效果的目标设定）
function c10071151.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c10071151.desfilter(chkc) end
	-- 检查场上是否存在至少1张满足条件的表侧表示魔法·陷阱卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c10071151.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示，提示内容为选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 让玩家从场上选择1张表侧表示的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c10071151.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，分类为破坏，目标为选择的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果①的效果处理函数，执行破坏对象卡的处理
function c10071151.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡（第1个目标）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏获取的对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义效果②的发动条件函数，判定是否为这张卡以外的自己的「光道」怪兽的效果发动
function c10071151.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(0x38) and rc:IsControler(tp)
end
-- 定义效果②的目标函数（必发效果，无需额外条件检查）
function c10071151.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息，分类为卡组送去墓地，预计处理3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 定义效果②的效果处理函数，执行从卡组送卡去墓地的处理
function c10071151.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将玩家卡组最上面的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
