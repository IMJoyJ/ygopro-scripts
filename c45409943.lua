--Luce the Dusk's Dark
-- 效果：
-- 自己墓地的恶魔族·天使族怪兽×3
-- 自己主要怪兽区域左端和右端的怪兽不会被效果破坏。
-- 「日暮之暗 露彻」的以下效果1回合各能使用1次。
-- 可以以对方场上1张卡为对象；从卡组把1只恶魔族·天使族怪兽送去墓地，那张卡破坏。
-- 自己场上的其他卡被效果破坏的场合（伤害步骤除外）：可以以场上1张卡为对象；那张卡破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册融合召唤手续、起动效果、诱发效果和永续效果
function s.initial_effect(c)
	-- 为该卡添加融合召唤手续，使用3个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- 从卡组把1只恶魔族·天使族怪兽送去墓地，那张卡破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 自己场上的其他卡被效果破坏的场合（伤害步骤除外）：可以以场上1张卡为对象；那张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"场上的卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon2)
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
	-- 自己主要怪兽区域左端和右端的怪兽不会被效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断墓地中的怪兽是否为恶魔族或天使族且为该卡的拥有者
function s.ffilter(c,fc)
	return c:GetOwner()==fc:GetControler() and c:IsRace(RACE_FAIRY+RACE_FIEND)
		and c:IsLocation(LOCATION_GRAVE)
end
-- 过滤函数，用于判断卡组中是否有恶魔族或天使族且能送去墓地的怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsAbleToGrave()
end
-- 设置效果目标，检查对方场上是否存在可破坏的卡以及自己卡组中是否存在可送去墓地的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己卡组中是否存在可送去墓地的怪兽
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，指定要送去墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，将卡组中的怪兽送去墓地并破坏对方场上目标卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只恶魔族或天使族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将怪兽送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		and tc:IsRelateToChain() then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断被破坏的卡是否为该玩家控制且在场上被效果破坏
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsReason(REASON_EFFECT)
end
-- 诱发效果的发动条件，判断是否有被效果破坏的卡
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- 设置第二效果的目标，选择场上任意1张卡作为目标
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 第二效果的处理函数，破坏场上目标卡
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，判断是否为左端或右端的怪兽
function s.indtg(e,c)
	return c:GetSequence()==0 or c:GetSequence()==4
end
