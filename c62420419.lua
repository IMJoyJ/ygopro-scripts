--大邪神 レシェフ
-- 效果：
-- 「大邪神的仪式」降临。从手卡丢弃1张魔法卡。结束阶段前获得对方场上1只怪兽的控制权。这个效果1个回合只能使用1次。
function c62420419.initial_effect(c)
	-- 在卡片的关联卡列表中添加「大邪神的仪式」的卡片密码
	aux.AddCodeList(c,60369732)
	c:EnableReviveLimit()
	-- 从手卡丢弃1张魔法卡。结束阶段前获得对方场上1只怪兽的控制权。这个效果1个回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62420419,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c62420419.cost)
	e1:SetTarget(c62420419.target)
	e1:SetOperation(c62420419.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：可丢弃的魔法卡
function c62420419.cfilter(c)
	return c:IsDiscardable() and c:IsType(TYPE_SPELL)
end
-- 效果发动的代价：从手牌中将1张魔法卡丢弃
function c62420419.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62420419.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手牌中的1张魔法卡并作为代价丢弃
	Duel.DiscardHand(tp,c62420419.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 选择对方场上1只可以改变控制权的怪兽为效果对象，并设置操作信息
function c62420419.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查对方场上是否存在可以作为效果对象且可以被夺取控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要获得控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以改变控制权的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：改变1只怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：直到结束阶段前获得选择的对方怪兽的控制权
function c62420419.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获得目标怪兽的控制权，该效果在结束阶段时重置
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
