--双天将 密迹
-- 效果：
-- 「双天脚之鸿鹄」＋「双天」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己的「双天」融合怪兽在1回合各有1次不会被战斗破坏。
-- ②：1回合1次，自己主要阶段才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
-- ③：自己场上有融合怪兽2只以上存在，对方场上的怪兽的效果发动时才能发动。那只怪兽破坏。
function c284224.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：需要1只卡号为11759079的怪兽和2只「双天」怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,11759079,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true,true)
	-- 「双天脚之鸿鹄」＋「双天」怪兽×2
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c284224.matcheck)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，自己的「双天」融合怪兽在1回合各有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c284224.indtg)
	e1:SetValue(c284224.indct)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(284224,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c284224.thtg)
	e2:SetOperation(c284224.thop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：自己场上有融合怪兽2只以上存在，对方场上的怪兽的效果发动时才能发动。那只怪兽破坏。
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
-- 融合素材检查：获得此卡融合召唤时使用的素材组，若素材中存在效果怪兽，则为自身注册一个编号为85360035的标志，该标志会在离场、回卡组、回手、除外、送墓等重置条件下被清除（返回场上不会清除）。
function c284224.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	end
end
-- 判断怪兽是否为「双天」融合怪兽，用于筛选①效果中可获得1回合1次战斗破坏抗性的己方怪兽。
function c284224.indtg(e,c)
	return c:IsSetCard(0x14f) and c:IsType(TYPE_FUSION)
end
-- 返回①效果赋予的战斗破坏耐性次数：若伤害事件是战斗造成的（REASON_BATTLE），则返回1，表示该次不会被战斗破坏；否则返回0。
function c284224.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 回手筛选：判断卡片是否为魔法·陷阱卡且当前可以被加入手卡（不受“不能加入手卡”等限制）。
function c284224.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动条件与操作信息设置：效果发动时检查对方场上是否存在至少1张符合条件的魔法·陷阱卡；若存在，则获取对方场上全部此类卡，并设置这次连锁将把它们全部返回持有者手卡的操作信息。
function c284224.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法判定：在效果发动判定（chk==0）时，确认对方场上存在至少1张可以回手的魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c284224.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上当前所有满足可回手条件的魔法·陷阱卡，用于后续设置操作信息（该效果不取对象，处理时取全部）。
	local g=Duel.GetMatchingGroup(c284224.thfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将本次连锁的效果分类标记为回手（CATEGORY_TOHAND），目标为全部满足条件的魔法·陷阱卡，数量为这些卡的数量，以便其他卡进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果处理：在效果处理时重新获取对方场上所有可回手的魔法·陷阱卡，若存在则全部送回持有者手卡。
function c284224.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新检索对方场上当前所有满足条件的魔法·陷阱卡，确保实际处理的是最新状态下的卡。
	local g=Duel.GetMatchingGroup(c284224.thfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将检索到的卡以“效果”为原因送回其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 辅助筛选：判断怪兽是否为表侧表示且为融合怪兽，用于检查③效果所需的自场融合怪兽数量。
function c284224.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- ③效果的发动条件：对方场上的怪兽发动怪兽效果，且该效果发动的卡仍在场上并保持关联（不是墓地/除外等），同时自己场上存在至少2只表侧表示融合怪兽。
function c284224.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- ③的额外条件：自己场上存在至少2只表侧表示融合怪兽。
		and Duel.IsExistingMatchingCard(c284224.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- ③效果的发动目标判定：检查对方发动效果的那只怪兽是否能够被破坏；若能，则设置破坏该怪兽的操作信息。
function c284224.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置操作信息：将本次连锁标记为破坏效果（CATEGORY_DESTROY），预定破坏的对象为刚刚对方发动效果的那只怪兽（eg）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- ③效果处理：若对方发动效果的那只怪兽仍与效果关联（未被无效或离场导致关联重置），则将其破坏。
function c284224.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 以“效果”为原因破坏对方发动效果的那只怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
