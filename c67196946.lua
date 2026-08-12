--スター・ブラスト
-- 效果：
-- 支付500的倍数的基本分才能发动。选自己手卡或者自己场上表侧表示存在的1只怪兽，那只怪兽的等级直到结束阶段时下降支付的基本分每500分1星。
function c67196946.initial_effect(c)
	-- 支付500的倍数的基本分才能发动。选自己手卡或者自己场上表侧表示存在的1只怪兽，那只怪兽的等级直到结束阶段时下降支付的基本分每500分1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c67196946.cost)
	e1:SetTarget(c67196946.tg)
	e1:SetOperation(c67196946.op)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：计算并让玩家选择并支付500的倍数的基本分，将下降的等级数记录在Label中
function c67196946.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付至少500点基本分
	if chk==0 then return Duel.CheckLPCost(tp,500,true) end
	-- 获取发动玩家当前的生命值
	local lp=Duel.GetLP(tp)
	-- 过滤出自己手卡或场上表侧表示存在的、等级在2以上的怪兽
	local g=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,2)
	local tg=g:GetMaxGroup(Card.GetLevel)
	local maxlv=math.min(tg:GetFirst():GetLevel(),255)
	local t={}
	local l=1
	while l<maxlv and l*500<=lp do
		t[l]=l*500
		l=l+1
	end
	-- 提示玩家选择要支付的基本分
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(67196946,0))  --"请选择要支付的基本分"
	-- 让玩家宣言一个要支付的基本分数值
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 扣除玩家宣言的基本分作为发动代价
	Duel.PayLPCost(tp,announce,true)
	e:SetLabel(announce/500)
end
-- 效果的目标选择（Target）处理：检查是否存在可选择的怪兽
function c67196946.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1只等级在2以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLevelAbove,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,2) end
end
-- 效果的运行（Operation）处理：选择1只怪兽并使其等级直到结束阶段时下降
function c67196946.op(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 过滤出自己手卡或场上表侧表示存在的、等级大于等于“下降星数+1”的怪兽
	local g=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,ct+1)
	if g:GetCount()>0 then
		-- 提示玩家选择等级要下降的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(67196946,1))  --"请选择等级要下降的怪兽"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc:IsLocation(LOCATION_MZONE) then
			-- 如果选择的怪兽在场上，则对该怪兽进行闪烁提示
			Duel.HintSelection(sg)
		end
		-- 向对方玩家确认选择的怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 如果选择的怪兽在手卡，则在确认后洗切手卡
		if tc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
		-- 那只怪兽的等级直到结束阶段时下降支付的基本分每500分1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		e1:SetValue(-ct)
		tc:RegisterEffect(e1)
	end
end
