--大逆転クイズ
-- 效果：
-- 将自己手卡和场上的卡全部送去墓地。猜自己卡组最上面1张卡的种类（魔法/陷阱/怪兽），若猜对，则将自己与对方的基本分值互换。
function c5990062.initial_effect(c)
	-- 将自己手卡和场上的卡全部送去墓地。猜自己卡组最上面1张卡的种类（魔法/陷阱/怪兽），若猜对，则将自己与对方的基本分值互换。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c5990062.cost)
	e1:SetTarget(c5990062.target)
	e1:SetOperation(c5990062.activate)
	c:RegisterEffect(e1)
end
-- 过滤出不能作为代价送去墓地的卡的条件函数
function c5990062.cfilter(c)
	return not c:IsAbleToGraveAsCost()
end
-- 检查发动代价：自己手卡和场上必须各有至少1张卡，且所有这些卡都必须能作为代价送去墓地
function c5990062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡和场上的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND+LOCATION_ONFIELD,0)
	g:RemoveCard(e:GetHandler())
	if chk==0 then return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)>0
		and g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)>0
		and not g:IsExists(c5990062.cfilter,1,nil) end
	-- 将这些卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检查效果发动条件：双方基本分不同，且自己卡组有至少1张卡
function c5990062.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方的基本分是否不相等（若相等则互换无意义，不能发动）
	if chk==0 then return Duel.GetLP(tp)~=Duel.GetLP(1-tp)
		-- 并且自己卡组最上方必须有至少1张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 效果处理：宣言卡片种类并确认卡组最上方的卡，若猜对则互换双方基本分
function c5990062.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上面1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱）
	local res=Duel.AnnounceType(tp)
	-- 确认自己卡组最上面1张卡
	Duel.ConfirmDecktop(tp,1)
	if (res==0 and tc:IsType(TYPE_MONSTER))
		or (res==1 and tc:IsType(TYPE_SPELL))
		or (res==2 and tc:IsType(TYPE_TRAP)) then
		-- 获取自己当前的基本分
		local lp1=Duel.GetLP(tp)
		-- 获取对方当前的基本分
		local lp2=Duel.GetLP(1-tp)
		-- 将自己的基本分设置为对方的基本分
		Duel.SetLP(tp,lp2)
		-- 将对方的基本分设置为自己的基本分
		Duel.SetLP(1-tp,lp1)
	end
	-- 将自己的卡组洗牌
	Duel.ShuffleDeck(tp)
end
