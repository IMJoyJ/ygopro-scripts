--渇きの風
-- 效果：
-- 「干渴之风」的①②的效果1回合各能使用1次。
-- ①：自己基本分回复的场合，以对方场上1只表侧表示怪兽为对象把这个效果发动。那只怪兽破坏。
-- ②：自己场上有「芳香」怪兽存在，自己基本分比对方多3000以上的场合，支付那个相差数值的基本分才能把这个效果发动。攻击力合计最多到为这个效果发动而支付的基本分数值以下为止，选对方场上的表侧表示怪兽破坏。
function c28265983.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己基本分回复的场合，以对方场上1只表侧表示怪兽为对象把这个效果发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28265983,1))  --"选择1只怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_RECOVER)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,28265983)
	e1:SetCondition(c28265983.descon1)
	e1:SetTarget(c28265983.destg1)
	e1:SetOperation(c28265983.desop1)
	c:RegisterEffect(e1)
	-- ②：自己场上有「芳香」怪兽存在，自己基本分比对方多3000以上的场合，支付那个相差数值的基本分才能把这个效果发动。攻击力合计最多到为这个效果发动而支付的基本分数值以下为止，选对方场上的表侧表示怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28265983,2))  --"选攻击力在支付的基本分数值以下的怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,28265984)
	e3:SetCondition(c28265983.descon2)
	e3:SetCost(c28265983.descost2)
	e3:SetTarget(c28265983.destg2)
	e3:SetOperation(c28265983.desop2)
	c:RegisterEffect(e3)
end
-- 效果发动时，确认回复基本分的玩家是否为效果持有者
function c28265983.descon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤函数，用于筛选对方场上的表侧表示怪兽
function c28265983.desfilter1(c)
	return c:IsFaceup()
end
-- 设置效果目标，选择对方场上1只表侧表示怪兽作为破坏对象
function c28265983.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c28265983.desfilter1(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c28265983.desfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果，将目标怪兽破坏
function c28265983.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选场上的芳香怪兽
function c28265983.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- 效果发动条件，确认自己场上有芳香怪兽且基本分比对方多3000以上
function c28265983.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上有芳香怪兽且基本分比对方多3000以上
	return Duel.IsExistingMatchingCard(c28265983.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLP(tp)-Duel.GetLP(1-tp)>=3000
end
-- 支付基本分作为效果发动的费用
function c28265983.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己与对方基本分的差值
	local lp=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	-- 检查是否能支付基本分费用
	if chk==0 then return Duel.CheckLPCost(tp,lp,true) end
	-- 支付基本分费用
	Duel.PayLPCost(tp,lp,true)
	e:SetLabel(lp)
end
-- 过滤函数，用于筛选攻击力不超过指定值的表侧表示怪兽
function c28265983.desfilter2(c,num)
	return c:IsFaceup() and c:IsAttackBelow(num)
end
-- 设置效果目标，选择攻击力不超过支付基本分值的对方怪兽
function c28265983.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己与对方基本分的差值
	local lp=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	-- 检查是否存在攻击力不超过支付基本分值的对方怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28265983.desfilter2,tp,0,LOCATION_MZONE,1,nil,lp) end
	-- 获取攻击力不超过支付基本分值的对方怪兽组
	local g=Duel.GetMatchingGroup(c28265983.desfilter2,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 筛选函数，用于选择攻击力总和不超过指定值的怪兽组
function c28265983.gselect(g,num)
	return g:GetSum(Card.GetAttack)<=num
end
-- 执行效果，将符合条件的对方怪兽破坏
function c28265983.desop2(e,tp,eg,ep,ev,re,r,rp)
	local num=e:GetLabel()
	-- 获取攻击力不超过支付基本分值的对方怪兽组
	local g=Duel.GetMatchingGroup(c28265983.desfilter2,tp,0,LOCATION_MZONE,nil,num)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:SelectSubGroup(tp,c28265983.gselect,false,1,#g,num)
	-- 将符合条件的怪兽组破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
