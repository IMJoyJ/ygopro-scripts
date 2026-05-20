--サイコ・ブレイド
-- 效果：
-- 「念力宝剑」在1回合只能发动1张。支付100的倍数的基本分才能把这张卡发动（最多2000）。
-- ①：装备怪兽的攻击力·守备力上升因为这张卡发动而支付的基本分数值。
function c75539614.initial_effect(c)
	-- 「念力宝剑」在1回合只能发动1张。支付100的倍数的基本分才能把这张卡发动（最多2000）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCountLimit(1,75539614+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c75539614.cost)
	e1:SetTarget(c75539614.target)
	e1:SetOperation(c75539614.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力·守备力上升因为这张卡发动而支付的基本分数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c75539614.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 装备限制
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 发动代价：检查并让玩家选择支付100的倍数（最多2000）的基本分，并将支付的数值作为标记记录在卡片上
function c75539614.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付至少100点基本分
	if chk==0 then return Duel.CheckLPCost(tp,100,true) end
	-- 获取玩家当前的生命值
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp,2000)/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	-- 让玩家选择（宣言）一个要支付的基本分数值
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 扣除玩家选择的基本分数值作为发动代价
	Duel.PayLPCost(tp,ac,true)
	e:GetHandler():RegisterFlagEffect(75539614,RESET_EVENT+RESETS_STANDARD,0,1,ac)
end
-- 效果的目标：选择场上1只表侧表示怪兽作为装备对象，并设置装备操作信息
function c75539614.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果的处理：将这张卡装备给选择的表侧表示怪兽
function c75539614.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 获取卡片上记录的已支付基本分数值，作为攻击力·守备力的上升值
function c75539614.val(e,c)
	local ct=e:GetHandler():GetFlagEffectLabel(75539614)
	if not ct then return 0 end
	return ct
end
