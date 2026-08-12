--神聖魔導王 エンディミオン
-- 效果：
-- ①：这张卡可以把自己场上的「魔法都市 恩底弥翁」放置的6个魔力指示物取除，从手卡·墓地特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
-- ③：1回合1次，从手卡丢弃1张魔法卡，以场上1张卡为对象才能发动。那张卡破坏。
function c40732515.initial_effect(c)
	-- ①：这张卡可以把自己场上的「魔法都市 恩底弥翁」放置的6个魔力指示物取除，从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c40732515.spcon)
	e1:SetOperation(c40732515.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤成功的场合，以自己墓地1张魔法卡为对象发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40732515,0))  --"墓地存在的1张魔法卡加入手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c40732515.condition)
	e2:SetTarget(c40732515.target)
	e2:SetOperation(c40732515.operation)
	c:RegisterEffect(e2)
	-- ③：1回合1次，从手卡丢弃1张魔法卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40732515,1))  --"场上存在的1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c40732515.descost)
	e3:SetTarget(c40732515.destg)
	e3:SetOperation(c40732515.desop)
	c:RegisterEffect(e3)
end
c40732515.mentioned_counter={
	[0x1]=true,
}
-- 筛选函数：筛选自己场上的「魔法都市 恩底弥翁」（卡号39910367），且其可以取除1个以上魔力指示物作为代价。
function c40732515.spcfilter(c,tp)
	return c:IsCode(39910367) and c:IsCanRemoveCounter(tp,0x1,1,REASON_COST)
end
-- 特殊召唤条件函数：统计自己场上所有「魔法都市 恩底弥翁」放置的魔力指示物总数，总数达到6个以上且主要怪兽区有空位时才能用①的方法特殊召唤。
function c40732515.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检索自己场上所有可取除魔力指示物的「魔法都市 恩底弥翁」。
	local g=Duel.GetMatchingGroup(c40732515.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	local ct=0
	-- 遍历检索到的「魔法都市 恩底弥翁」卡组中的每一张卡。
	for tc in aux.Next(g) do
		ct=ct+tc:GetCounter(0x1)
	end
	-- 判定魔力指示物总数是否达到6个，并且主要怪兽区还有可用空格。
	return ct>=6 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 特殊召唤的处理：把自己场上「魔法都市 恩底弥翁」放置的6个魔力指示物取除；只有1张时直接取除6个，有多张时分6次让玩家依次选择卡片各取除1个。
function c40732515.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 检索自己场上所有可取除魔力指示物的「魔法都市 恩底弥翁」。
	local g=Duel.GetMatchingGroup(c40732515.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	if #g==1 then
		g:GetFirst():RemoveCounter(tp,0x1,6,REASON_COST)
	else
		for i=1,6 do
		-- 向玩家提示「请选择要取除指示物的卡」。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40732515,2))  --"请选择要取除指示物的卡"
		-- 让玩家从自己场上的「魔法都市 恩底弥翁」中选择1张卡，用于取除魔力指示物。
		local tg=Duel.SelectMatchingCard(tp,c40732515.spcfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
		tg:GetFirst():RemoveCounter(tp,0x1,1,REASON_COST)
		end
	end
end
-- 发动条件：确认这张卡是用①的方法特殊召唤成功的。
function c40732515.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选函数：筛选可以加入手卡的魔法卡。
function c40732515.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 对象选择处理：以自己墓地1张可以加入手卡的魔法卡为对象，并设置将那张卡加入手卡的操作信息。
function c40732515.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c40732515.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示「请选择要加入手牌的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的魔法卡作为对象。
	local g=Duel.SelectTarget(tp,c40732515.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将对象的魔法卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：若对象的卡仍与此效果相关，则将那张卡从墓地加入手卡，随后洗切手卡。
function c40732515.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象的魔法卡以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
	end
end
-- 筛选函数：筛选可以丢弃的魔法卡（作为代价）。
function c40732515.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 代价处理：发动时需从手卡丢弃1张魔法卡作为代价。
function c40732515.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己手卡是否存在可以丢弃的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40732515.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从手卡选择1张魔法卡，以代价丢弃。
	Duel.DiscardHand(tp,c40732515.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象选择处理：检查场上是否存在能成为对象的卡，以场上1张卡为对象，并设置破坏的操作信息。
function c40732515.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动时检查双方场上是否存在至少1张可以成为此效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为破坏对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏对象的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象的卡仍与此效果相关，则将其破坏。
function c40732515.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象的卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
