--友情 YU－JYO
-- 效果：
-- ①：向对方玩家提出握手。对方答应握手的场合，双方基本分变成双方基本分合计数值的一半。自己手卡有「团结 UNITY」的场合，可以把那张卡给对方观看。那个场合，双方握手，这张卡的效果适用。
function c81332143.initial_effect(c)
	-- ①：向对方玩家提出握手。对方答应握手的场合，双方基本分变成双方基本分合计数值的一半。自己手卡有「团结 UNITY」的场合，可以把那张卡给对方观看。那个场合，双方握手，这张卡的效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c81332143.activate)
	c:RegisterEffect(e1)
end
-- 效果处理：向对方提出握手，根据对方是否答应或自己是否展示「团结 UNITY」来决定是否将双方基本分变成合计数值的一半。
function c81332143.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	-- 检查自己手卡是否存在「团结 UNITY」，并由自己选择是否给对方观看。
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,14731897) and Duel.SelectYesNo(tp,aux.Stringid(81332143,2)) then  --"是否要把「团结 UNITY」给对方观看？"
		-- 设置提示信息为请选择给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手卡选择1张「团结 UNITY」。
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,14731897)
		-- 给对方玩家确认选中的「团结 UNITY」。
		Duel.ConfirmCards(1-tp,g)
		-- 将自己的手卡洗切。
		Duel.ShuffleHand(tp)
		opt=1
	end
	if opt==0 then
		-- 未展示「团结 UNITY」时，由对方玩家选择是否同意握手（同意或拒绝）。
		opt=Duel.SelectOption(1-tp,aux.Stringid(81332143,0),aux.Stringid(81332143,1))  --"同意握手/拒绝握手"
	else
		-- 已展示「团结 UNITY」时，对方玩家只能选择同意握手。
		opt=Duel.SelectOption(1-tp,aux.Stringid(81332143,0))  --"同意握手"
	end
	if opt==0 then
		-- 计算双方基本分合计数值的一半（向上取整）。
		local lp=math.ceil((Duel.GetLP(tp)+Duel.GetLP(1-tp))/2)
		-- 将自己的基本分变成该合计数值的一半。
		Duel.SetLP(tp,lp)
		-- 将对方的基本分变成该合计数值的一半。
		Duel.SetLP(1-tp,lp)
	end
end
