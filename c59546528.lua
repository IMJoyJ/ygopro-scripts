--氷結界の舞姫
-- 效果：
-- ①：1回合1次，自己场上有其他的「冰结界」怪兽存在的场合，把手卡的「冰结界」怪兽任意数量给对方观看，以那个数量的对方场上的里侧表示的魔法·陷阱卡为对象才能发动。那些里侧表示卡回到手卡。
function c59546528.initial_effect(c)
	-- ①：1回合1次，自己场上有其他的「冰结界」怪兽存在的场合，把手卡的「冰结界」怪兽任意数量给对方观看，以那个数量的对方场上的里侧表示的魔法·陷阱卡为对象才能发动。那些里侧表示卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59546528,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c59546528.condition)
	e1:SetCost(c59546528.cost)
	e1:SetTarget(c59546528.target)
	e1:SetOperation(c59546528.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「冰结界」卡
function c59546528.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 发动条件判定
function c59546528.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的表侧表示的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c59546528.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件：手卡中未公开的「冰结界」怪兽
function c59546528.cfilter2(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 过滤条件：对方场上里侧表示且能回到手牌的卡
function c59546528.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 发动代价处理
function c59546528.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手卡中是否存在至少1张「冰结界」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59546528.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 获取对方场上可作为对象的里侧表示魔法·陷阱卡数量的最大值
	local ct=Duel.GetTargetCount(c59546528.filter,tp,0,LOCATION_SZONE,nil)
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择任意数量（不超过对方场上里侧魔陷数量）的手卡中的「冰结界」怪兽
	local cg=Duel.SelectMatchingCard(tp,c59546528.cfilter2,tp,LOCATION_HAND,0,1,ct,nil)
	-- 将选择的卡片给对方玩家确认
	Duel.ConfirmCards(1-tp,cg)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
	e:SetLabel(cg:GetCount())
end
-- 效果目标选择
function c59546528.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c59546528.filter(chkc) end
	-- 在发动阶段，检查对方场上是否存在至少1张里侧表示的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c59546528.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择与展示数量相同的对方场上的里侧表示魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c59546528.filter,tp,0,LOCATION_SZONE,e:GetLabel(),e:GetLabel(),nil)
	-- 设置效果处理信息：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理
function c59546528.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍存在于场上且仍为里侧表示的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFacedown,nil)
	if g:GetCount()>0 then
		-- 将目标卡片送回持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
