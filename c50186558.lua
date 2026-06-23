--守護竜の結界
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到对方回合结束时上升场上的连接怪兽的连接标记合计×100。
-- ②：1回合1次，只让自己场上的龙族怪兽1只被战斗·效果破坏的场合，可以作为代替从手卡·卡组把1只通常怪兽送去墓地。
function c50186558.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到对方回合结束时上升场上的连接怪兽的连接标记合计×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50186558,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,50186558)
	e2:SetTarget(c50186558.atktg)
	e2:SetOperation(c50186558.atkop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，只让自己场上的龙族怪兽1只被战斗·效果破坏的场合，可以作为代替从手卡·卡组把1只通常怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c50186558.desreptg)
	e3:SetValue(c50186558.desrepval)
	e3:SetOperation(c50186558.desrepop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为表侧表示的龙族怪兽
function c50186558.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 过滤函数，用于判断是否为表侧表示的连接怪兽
function c50186558.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果①的发动时点处理函数，用于选择目标怪兽和检查是否存在连接怪兽
function c50186558.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50186558.atkfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c50186558.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示的连接怪兽
		and Duel.IsExistingMatchingCard(c50186558.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只表侧表示的龙族怪兽作为效果对象
	Duel.SelectTarget(tp,c50186558.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的发动处理函数，计算连接怪兽总连接标记并为对象怪兽增加攻击力和守备力
function c50186558.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的连接怪兽组成的组
	local g=Duel.GetMatchingGroup(c50186558.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetSum(Card.GetLink)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个使目标怪兽攻击力上升的永续效果，数值为连接怪兽数量×100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤函数，用于判断是否为表侧表示、在主要怪兽区、属于龙族、属于自己、因战斗或效果被破坏且未被代替破坏的怪兽
function c50186558.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤函数，用于判断是否为可送去墓地的通常怪兽
function c50186558.tgfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- 效果②的发动时点处理函数，检查是否满足代替破坏条件并确认手卡/卡组中存在通常怪兽
function c50186558.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetCount()==1 and eg:IsExists(c50186558.repfilter,1,nil,tp)
		-- 检查自己手卡或卡组中是否存在至少1只通常怪兽
		and Duel.IsExistingMatchingCard(c50186558.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否发动效果②
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回一个布尔值表示该怪兽是否满足代替破坏条件
function c50186558.desrepval(e,c)
	return c50186558.repfilter(c,e:GetHandlerPlayer())
end
-- 效果②的发动处理函数，选择一只通常怪兽送去墓地
function c50186558.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一只通常怪兽作为代替破坏的对象
	local g=Duel.SelectMatchingCard(tp,c50186558.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将所选的通常怪兽以效果原因送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
