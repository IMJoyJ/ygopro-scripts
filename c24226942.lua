--カオス・ネフティス
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，场上的卡被效果破坏的场合，从自己墓地把「混沌奈芙提斯」以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以对方场上1张卡和对方墓地2张卡为对象才能发动。那些卡除外。
function c24226942.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡·墓地存在，场上的卡被效果破坏的场合，从自己墓地把「混沌奈芙提斯」以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,24226942)
	e2:SetCondition(c24226942.spcon)
	e2:SetCost(c24226942.spcost)
	e2:SetTarget(c24226942.sptg)
	e2:SetOperation(c24226942.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1张卡和对方墓地2张卡为对象才能发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c24226942.rmtg)
	e3:SetOperation(c24226942.rmop)
	c:RegisterEffect(e3)
end
-- 用于判断被破坏的卡是否来自场上且由效果破坏
function c24226942.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
-- 判断是否满足①效果的发动条件
function c24226942.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c24226942.cfilter,1,nil) and (c:IsLocation(LOCATION_HAND) or not eg:IsContains(c))
end
-- 用于筛选满足除外条件的墓地怪兽
function c24226942.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsCode(24226942)
end
-- 检查并选择满足条件的2只怪兽进行除外
function c24226942.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足除外条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c24226942.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查是否能选出2只满足条件的怪兽
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2只怪兽
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选中的怪兽除外作为费用
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 判断是否可以将此卡特殊召唤
function c24226942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c24226942.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 设置除外效果的目标
function c24226942.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 判断对方场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		-- 判断对方墓地是否存在2张可除外的卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张卡作为除外对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地的2张卡作为除外对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,2,2,nil)
	g1:Merge(g2)
	-- 设置除外效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 执行除外操作
function c24226942.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
