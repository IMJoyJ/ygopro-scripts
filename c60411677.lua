--ジャッジメント・オブ・アヌビス
-- 效果：
-- 这张卡不能通常召唤。自己墓地有「王家的神殿」或陷阱卡合计3种类以上存在的状态，让那之内的2种类各1张用喜欢的顺序回到卡组下面的场合才能从手卡·墓地特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从卡组把1只「带刻印者」加入手卡。
-- ②：自己场上的魔法·陷阱卡被效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果
function s.initial_effect(c)
	-- 将「王家的神殿」和「带刻印者」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,29762407,97522863)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(0)
	c:RegisterEffect(e0)
	-- 自己墓地有「王家的神殿」或陷阱卡合计3种类以上存在的状态，让那之内的2种类各1张用喜欢的顺序回到卡组下面的场合才能从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡送去墓地才能发动。从卡组把1只「带刻印者」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上的魔法·陷阱卡被效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤自身墓地中的「王家的神殿」或陷阱卡，且该卡必须能回到卡组
function s.sprfilter(c)
	return (c:IsCode(29762407) or c:IsType(TYPE_TRAP)) and c:IsAbleToDeckAsCost()
end
-- 特殊召唤规则的条件判断函数
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查墓地中满足条件的卡片是否包含至少3种不同的卡名
	return Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)>=3
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少2张满足条件的卡
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤规则的消耗/目标选择函数
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足条件的卡片组
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送选择返回卡组的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从卡片组中筛选出2张卡名不同的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,true,2,2)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作函数
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or g:GetCount()~=2 then return end
	-- 为选中的卡片显示被选择的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡片以玩家喜欢的顺序放回卡组最下方
	aux.PlaceCardsOnDeckBottom(tp,g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①的发动代价判断与执行函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手牌的这张卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中卡名为「带刻印者」且能加入手牌的怪兽
function s.thfilter(c)
	return c:IsCode(97522863) and c:IsAbleToHand()
end
-- 效果①的发的发动准备函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「带刻印者」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送选择加入手牌的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「带刻印者」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤原本在自己场上且因效果被破坏的魔法·陷阱卡
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT) and c:GetPreviousTypeOnField()&(TYPE_SPELL+TYPE_TRAP)~=0
end
-- 效果②的发动条件判断函数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果②的发动准备函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送选择破坏对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
