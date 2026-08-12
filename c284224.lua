--双天将 密迹
-- 效果：
-- 「双天脚之鸿鹄」＋「双天」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的「双天」融合怪兽在1回合各有1次不会被战斗破坏。
-- ②：1回合1次，自己主要阶段才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
-- ③：自己场上有融合怪兽2只以上存在，对方场上的怪兽的效果发动时才能发动。那只怪兽破坏。
function c284224.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号11759079的怪兽和2个满足「双天」融合怪兽条件的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,11759079,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true,true)
	-- ①：只要这张卡在怪兽区域存在，自己的「双天」融合怪兽在1回合各有1次不会被战斗破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c284224.matcheck)
	c:RegisterEffect(e0)
	-- ②：1回合1次，自己主要阶段才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c284224.indtg)
	e1:SetValue(c284224.indct)
	c:RegisterEffect(e1)
	-- ③：自己场上有融合怪兽2只以上存在，对方场上的怪兽的效果发动时才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(284224,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c284224.thtg)
	e2:SetOperation(c284224.thop)
	c:RegisterEffect(e2)
	-- 为融合怪兽添加融合素材检查效果，若融合素材包含效果怪兽则记录标记
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(284224,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,284224)
	e3:SetCondition(c284224.descon)
	e3:SetTarget(c284224.destg)
	e3:SetOperation(c284224.desop)
	c:RegisterEffect(e3)
end
-- 设置永续效果，使「双天」融合怪兽在1回合内有1次不会被战斗破坏
function c284224.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
-- 过滤条件：满足「双天」融合怪兽的怪兽
function c284224.indtg(e,c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_FUSION)
end
-- 判断是否为战斗破坏，是则返回1次不被破坏，否则返回0次
function c284224.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤条件：魔法·陷阱卡且可以送入手卡
function c284224.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置发动时的处理条件，检查对方场上是否存在魔法·陷阱卡
function c284224.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c284224.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有满足条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c284224.thfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定将卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 发动效果，将对方场上的魔法·陷阱卡送回手卡
function c284224.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c284224.thfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将卡送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示的融合怪兽
function c284224.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 设置发动条件，对方怪兽效果发动时且自己场上有2只以上融合怪兽
function c284224.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上有2只以上融合怪兽
		and Duel.IsExistingMatchingCard(c284224.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 设置发动时的处理条件，检查对方怪兽是否可以被破坏
function c284224.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置连锁操作信息，指定将卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 发动效果，破坏对方怪兽
function c284224.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
