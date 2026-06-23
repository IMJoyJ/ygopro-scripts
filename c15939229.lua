--DDD双暁王カリ・ユガ
-- 效果：
-- 8星「DD」怪兽×2
-- ①：这张卡超量召唤成功的回合，这张卡以外的场上的卡的效果不能发动并无效化。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动。
-- ③：把这张卡1个超量素材取除，以自己墓地1张「契约书」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c15939229.initial_effect(c)
	-- 为卡片添加超量召唤手续，使用满足「DD」卡组条件的8星怪兽作为素材进行超量召唤，需要2个素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xaf),8,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功的回合，这张卡以外的场上的卡的效果不能发动并无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c15939229.sumsuc)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。场上的魔法·陷阱卡全部破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15939229,0))  --"场上的魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(c15939229.cost)
	e2:SetTarget(c15939229.destg)
	e2:SetOperation(c15939229.desop)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除，以自己墓地1张「契约书」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15939229,1))  --"盖放魔法·陷阱"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c15939229.cost)
	e3:SetTarget(c15939229.settg)
	e3:SetOperation(c15939229.setop)
	c:RegisterEffect(e3)
end
-- 当此卡超量召唤成功时，为该卡添加3个效果：1.禁止对方发动场上卡的效果；2.使场上卡的效果无效；3.使连锁处理时无效化对方发动的效果
function c15939229.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_XYZ) then return end
	-- 创建一个禁止对方发动场上卡效果的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c15939229.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabel(c:GetFieldID())
	-- 将该禁止发动效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 创建一个使场上卡效果无效的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetTarget(c15939229.disable)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabel(c:GetFieldID())
	-- 将该使效果无效的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 创建一个连锁处理时无效化对方发动效果的效果，并注册给玩家
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetCondition(c15939229.discon)
	e3:SetOperation(c15939229.disop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetLabel(c:GetFieldID())
	-- 将该连锁无效化效果注册给玩家
	Duel.RegisterEffect(e3,tp)
	c:RegisterFlagEffect(15939229,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,c:GetFieldID())
end
-- 判断是否为对方发动的效果，且该效果不是来自本卡
function c15939229.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:GetFlagEffectLabel(15939229)~=e:GetLabel()
end
-- 判断是否为场上卡，且该卡不是来自本卡
function c15939229.disable(e,c)
	return c:GetFlagEffectLabel(15939229)~=e:GetLabel() and (not c:IsType(TYPE_MONSTER) or (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT))
end
-- 判断连锁是否来自场上，且该连锁不是来自本卡
function c15939229.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 获取当前连锁的触发位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0 and rc:GetFlagEffectLabel(15939229)~=e:GetLabel()
end
-- 使当前连锁的效果无效
function c15939229.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 消耗1个超量素材作为发动成本
function c15939229.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义破坏目标过滤器，筛选魔法或陷阱类型卡片
function c15939229.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置破坏效果的目标，检查场上是否存在魔法或陷阱卡
function c15939229.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c15939229.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有魔法或陷阱卡的卡片组
	local g=Duel.GetMatchingGroup(c15939229.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，指定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，将目标魔法或陷阱卡破坏
function c15939229.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有魔法或陷阱卡的卡片组
	local g=Duel.GetMatchingGroup(c15939229.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 执行破坏操作，将目标魔法或陷阱卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 定义盖放目标过滤器，筛选「契约书」卡组的魔法或陷阱卡
function c15939229.setfilter(c)
	return c:IsSetCard(0xae) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置盖放效果的目标，检查墓地是否存在符合条件的卡
function c15939229.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c15939229.setfilter(chkc) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地是否存在符合条件的卡
		and Duel.IsExistingTarget(c15939229.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c15939229.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，指定盖放效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行盖放操作，将目标卡盖放在玩家场上
function c15939229.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡盖放在玩家场上
		Duel.SSet(tp,tc)
	end
end
