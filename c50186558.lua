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
	-- 这个卡名的①的效果1回合只能使用1次。①：以自己场上1只龙族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到对方回合结束时上升场上的连接怪兽的连接标记合计×100。
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
-- 过滤函数：用于选择①效果的对象，要求卡为表侧表示且种族为龙族。
function c50186558.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 过滤函数：用于统计连接标记，要求卡为表侧表示且为连接怪兽。
function c50186558.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- ①效果的发动条件检查与取对象处理：当处于选择对象阶段时，验证候选对象是己方场上表侧表示的龙族怪兽；当处于发动合法性检查阶段（chk==0）时，确认己方场上存在1只符合条件的目标龙族怪兽，且双方场上存在至少1只表侧连接怪兽。
function c50186558.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50186558.atkfilter(chkc) end
	-- 发动合法性检查：己方主要怪兽区是否存在1只表侧表示的可选龙族怪兽（作为取对象目标）。
	if chk==0 then return Duel.IsExistingTarget(c50186558.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动合法性检查：双方场上是否存在至少1只表侧连接怪兽（用于计算连接标记合计）。
		and Duel.IsExistingMatchingCard(c50186558.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发出选择提示，要求选择一张表侧表示的卡（之后选择目标时显示该提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 由操作玩家从自己场上选择1只表侧表示的龙族怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c50186558.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：统计双方场上表侧连接怪兽的连接标记合计，若大于0且对象怪兽仍在场且与效果关联，则为其生成攻击力·守备力上升效果，上升值为连接标记合计×100，持续到对方回合结束。
function c50186558.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有表侧表示的连接怪兽，用于累加连接标记数量。
	local g=Duel.GetMatchingGroup(c50186558.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetSum(Card.GetLink)
	-- 取得①效果发动时选择的1只龙族怪兽对象。
	local tc=Duel.GetFirstTarget()
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力直到对方回合结束时上升场上的连接怪兽的连接标记合计×100。
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
-- 代替破坏的适用判定：要破坏的怪兽必须是表侧表示、位于主要怪兽区、龙族、自己控制，且破坏原因是战斗或效果破坏，并且不能已经是代替破坏处理中（未经过REASON_REPLACE）。
function c50186558.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_DRAGON) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 送墓素材过滤：从手卡·卡组选择通常怪兽，要求该卡是通常怪兽且可以被送去墓地。
function c50186558.tgfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- ②代替破坏的触发条件：本次破坏的怪兽只有1只且满足代替对象条件，并且手卡·卡组中存在1只可送墓的通常怪兽。
function c50186558.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:GetCount()==1 and eg:IsExists(c50186558.repfilter,1,nil,tp)
		-- 继续检查手卡·卡组中是否存在1只满足条件的通常怪兽可供送去墓地。
		and Duel.IsExistingMatchingCard(c50186558.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否发动②的代替破坏效果（将破坏改为送墓通常怪兽）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的判定函数：将实际要被破坏的怪兽交给repfilter判断它是否满足“自己场上的龙族怪兽1只”且被战斗/效果破坏的条件。
function c50186558.desrepval(e,c)
	return c50186558.repfilter(c,e:GetHandlerPlayer())
end
-- ②代替破坏效果的处理：玩家从手卡·卡组选择1只通常怪兽，将其送去墓地，代替原本的破坏。
function c50186558.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示，要求选择一张要送去墓地的卡（之后选择时显示该提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己的手卡·卡组中选择1只通常怪兽（用于代替破坏的送墓）。
	local g=Duel.SelectMatchingCard(tp,c50186558.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选择的通常怪兽以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
