--竜星の気脈
-- 效果：
-- ①：得到自己墓地的「龙星」怪兽的属性种类数量的以下效果。
-- ●2种类以上：自己场上的「龙星」怪兽的攻击力上升500。
-- ●3种类以上：自己场上的「龙星」怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
-- ●4种类以上：对方不能把怪兽盖放，对方场上的表侧表示怪兽全部变成攻击表示。
-- ●5种类以上：把这张卡送去墓地才能发动。场上的卡全部破坏。
function c43577607.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●2种类以上：自己场上的「龙星」怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c43577607.atktg)
	e2:SetValue(500)
	e2:SetCondition(c43577607.effcon)
	e2:SetLabel(2)
	c:RegisterEffect(e2)
	-- ●3种类以上：自己场上的「龙星」怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c43577607.reptg)
	e3:SetValue(c43577607.repval)
	e3:SetOperation(c43577607.repop)
	e3:SetCondition(c43577607.effcon)
	e3:SetLabel(3)
	c:RegisterEffect(e3)
	-- ●4种类以上：对方不能把怪兽盖放
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_MSET)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(c43577607.effcon)
	e4:SetLabel(4)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e5:SetTarget(c43577607.sumlimit)
	c:RegisterEffect(e5)
	-- ●4种类以上：对方场上的表侧表示怪兽全部变成攻击表示
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_SET_POSITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetValue(POS_FACEUP_ATTACK)
	e6:SetCondition(c43577607.effcon)
	e6:SetLabel(4)
	c:RegisterEffect(e6)
	-- ●5种类以上：把这张卡送去墓地才能发动。场上的卡全部破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(43577607,0))  --"全部破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCondition(c43577607.effcon)
	e7:SetCost(c43577607.descost)
	e7:SetTarget(c43577607.destg)
	e7:SetOperation(c43577607.desop)
	e7:SetLabel(5)
	c:RegisterEffect(e7)
end
-- 筛选墓地中卡名含有「龙星」的怪兽卡，用于统计属性和作为效果条件的依据。
function c43577607.confilter(c)
	return c:IsSetCard(0x9e) and c:IsType(TYPE_MONSTER)
end
-- 效果条件函数：统计自己墓地中「龙星」怪兽的属性种类数，若大于等于效果Label中设定的要求种类数（2/3/4/5）则条件成立，使对应效果适用。
function c43577607.effcon(e)
	-- 获取当前效果持有者玩家墓地中所有满足confilter的「龙星」怪兽（不取对象，用于统计属性种类数）。
	local g=Duel.GetMatchingGroup(c43577607.confilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetAttribute)>=e:GetLabel()
end
-- 攻击力增益效果的适用对象判定：只要怪兽是「龙星」系列，就作为攻击力上升500的适用对象。
function c43577607.atktg(e,c)
	return c:IsSetCard(0x9e)
end
-- 代替破坏的怪兽过滤器：判定怪兽是否表侧表示、是「龙星」系列、由效果持有者控制、位于主要怪兽区，且正处于被战斗或效果破坏（且不是由其他代替破坏效果产生）的状态。
function c43577607.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9e) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动时机判定：首先确认这张卡自身没有被预定破坏，且本次将被破坏的怪兽中存在满足repfilter的「龙星」怪兽；若满足则进入询问。
function c43577607.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c43577607.repfilter,1,nil,tp) end
	-- 弹出询问框，让效果持有者选择是否用这张卡代替将被破坏的「龙星」怪兽送去墓地（选择是则发动代破效果）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- Value回调函数：当有怪兽将被破坏时，根据该怪兽是否满足repfilter来判断是否可由这张卡代替破坏；返回真则该次破坏改为把这张卡送墓。
function c43577607.repval(e,c)
	return c43577607.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的实际处理：将这张卡自身送去墓地（代替原本要被破坏的「龙星」怪兽）。
function c43577607.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡送入墓地，破坏代替动作完成，reason为效果。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 限制对方以里侧表示形式把怪兽特殊召唤：若特殊召唤的表示形式包含POS_FACEDOWN（即里侧守备或里侧攻击）则不允许，从而配合“对方不能把怪兽盖放”的限制。
function c43577607.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumpos&POS_FACEDOWN)>0
end
-- 破坏全场的起动效果的cost判定：确认这张卡可以送去墓地作为cost；如果可以，则实际执行送墓cost。
function c43577607.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 支付发动代价：把这张卡自身从魔陷区送去墓地，原因记作COST。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 全场破坏效果的发动条件与对象设定：发动时确认场上存在除这张卡以外的卡；然后获取场上全部卡片，并将操作信息设为破坏这些卡。
function c43577607.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：检查场上是否存在至少1张除这张卡以外的卡片，满足则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有卡片（包括双方怪兽区和魔法陷阱区的全部卡）作为要被破坏的对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置本次连锁的操作信息，声明要破坏的对象为g中的全部卡，数量为g的卡片数量，用于触发相关卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时重新获取当前场上的全部卡，若数量大于0则全部破坏（此时这张卡已因cost不在场上，所以实际破坏的是场上其余卡片）。
function c43577607.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时获取当前场上所有卡的集合，用于执行破坏。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将集合g中的卡全部破坏，破坏原因记为效果。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
