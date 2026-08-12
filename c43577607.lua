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
	-- ●4种类以上：对方不能把怪兽盖放，对方场上的表侧表示怪兽全部变成攻击表示。
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
	-- ●4种类以上：对方不能把怪兽盖放，对方场上的表侧表示怪兽全部变成攻击表示。
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
-- 过滤函数，返回满足条件的「龙星」怪兽（怪兽卡类型）
function c43577607.confilter(c)
	return c:IsSetCard(0x9e) and c:IsType(TYPE_MONSTER)
end
-- 判断当前满足条件的属性种类数量是否大于等于效果标签值（即是否满足对应效果触发条件）
function c43577607.effcon(e)
	-- 获取自己墓地满足条件的「龙星」怪兽数量
	local g=Duel.GetMatchingGroup(c43577607.confilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetAttribute)>=e:GetLabel()
end
-- 判断目标怪兽是否为「龙星」怪兽
function c43577607.atktg(e,c)
	return c:IsSetCard(0x9e)
end
-- 过滤函数，返回满足条件的「龙星」怪兽（表侧表示、自己控制、在怪兽区、因战斗或效果破坏且非代替破坏）
function c43577607.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9e) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的触发条件（该卡未被预定破坏且存在满足条件的破坏对象）
function c43577607.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c43577607.repfilter,1,nil,tp) end
	-- 让玩家选择是否发动该效果（提示文字为96）
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回该卡是否满足代替破坏的条件
function c43577607.repval(e,c)
	return c43577607.repfilter(c,e:GetHandlerPlayer())
end
-- 将该卡送去墓地作为代替破坏的效果处理
function c43577607.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡以效果原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- 限制对方不能将怪兽以背面向上的形式特殊召唤
function c43577607.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumpos&POS_FACEDOWN)>0
end
-- 支付将该卡送去墓地作为发动cost的条件
function c43577607.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将该卡以cost原因送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置发动时的破坏效果目标信息
function c43577607.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否场上存在至少一张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前处理的连锁的操作信息，包括破坏效果的分类、目标卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将目标卡全部破坏
function c43577607.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因破坏目标卡组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
