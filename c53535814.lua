--氷結界の浄玻璃
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有其他的「冰结界」怪兽存在，每次对方支付基本分来让卡的效果发动让对方失去500基本分。
-- ②：以自己墓地的「冰结界」怪兽以及对方墓地的卡各最多2张为对象才能发动。那些卡回到卡组。
-- ③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
function c53535814.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，每次对方支付基本分来让卡的效果发动让对方失去500基本分。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PAY_LPCOST)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c53535814.regop)
	c:RegisterEffect(e0)
	-- ②：以自己墓地的「冰结界」怪兽以及对方墓地的卡各最多2张为对象才能发动。那些卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c53535814.llpop)
	c:RegisterEffect(e1)
	-- ③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53535814,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53535814)
	e2:SetTarget(c53535814.tdtg)
	e2:SetOperation(c53535814.tdop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53535814,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,53535815)
	-- 将墓地的这张卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c53535814.poscon)
	e3:SetTarget(c53535814.postg)
	e3:SetOperation(c53535814.posop)
	c:RegisterEffect(e3)
end
-- 判断场上是否存在「冰结界」怪兽的过滤函数
function c53535814.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 当对方支付基本分时，若己方场上有「冰结界」怪兽，则记录一个标记
function c53535814.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==1-tp and re:IsActivated()
		-- 判断己方场上是否存在「冰结界」怪兽
		and Duel.IsExistingMatchingCard(c53535814.cfilter,tp,LOCATION_MZONE,0,1,c) then
		c:RegisterFlagEffect(53535814,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- 当连锁处理结束时，若己方场上有「冰结界」怪兽且有标记，则对对方造成500基本分伤害
function c53535814.llpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==1-tp and c:GetFlagEffect(53535814)>0
		-- 判断己方场上是否存在「冰结界」怪兽
		and Duel.IsExistingMatchingCard(c53535814.cfilter,tp,LOCATION_MZONE,0,1,c) then
		-- 提示对方发动了此卡的效果
		Duel.Hint(HINT_CARD,0,53535814)
		-- 使对方基本分减少500
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-500)
	end
end
-- 筛选墓地中可返回卡组的「冰结界」怪兽的过滤函数
function c53535814.tdfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 选择返回卡组的卡片的处理函数
function c53535814.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查己方墓地是否存在「冰结界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c53535814.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方墓地是否存在可返回卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择己方墓地的「冰结界」怪兽
	local g1=Duel.SelectTarget(tp,c53535814.tdfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地的卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,2,nil)
	g1:Merge(g2)
	-- 设置操作信息为将卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- 执行返回卡组的操作
function c53535814.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将目标卡组送回卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断场上是否存在「冰结界」怪兽的条件函数
function c53535814.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c53535814.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断目标怪兽是否为攻击表示且可改变表示形式的过滤函数
function c53535814.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 选择攻击表示怪兽的处理函数
function c53535814.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53535814.posfilter(chkc) end
	-- 检查己方场上是否存在攻击表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53535814.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上攻击表示的怪兽
	local g=Duel.SelectTarget(tp,c53535814.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 执行改变表示形式的操作
function c53535814.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsAttackPos() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
