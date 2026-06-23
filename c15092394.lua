--RR－エトランゼ・ファルコン
-- 效果：
-- 5星怪兽×2
-- ①：这张卡有超量怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ②：这张卡被对方破坏送去墓地的场合，以「急袭猛禽-异邦猎鹰」以外的自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡在那张卡下面重叠作为超量素材。
function c15092394.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用等级为5、数量为2的怪兽作为素材
	aux.AddXyzProcedure(c,nil,5,2)
	-- ①：这张卡有超量怪兽在作为超量素材的场合，得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15092394,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c15092394.descon)
	e1:SetCost(c15092394.descost)
	e1:SetTarget(c15092394.destg)
	e1:SetOperation(c15092394.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合，以「急袭猛禽-异邦猎鹰」以外的自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15092394,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c15092394.spcon)
	e2:SetTarget(c15092394.sptg)
	e2:SetOperation(c15092394.spop)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：此卡的超量素材中存在超量怪兽
function c15092394.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
-- 支付效果代价：从自己场上移除1个超量素材
function c15092394.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标：选择对方场上1只怪兽作为效果对象
function c15092394.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将被破坏的怪兽加入处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：将给予对方的伤害值加入处理对象
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 执行效果处理：破坏目标怪兽并给予对方其原本攻击力数值的伤害
function c15092394.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并执行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给予对方相当于目标怪兽原本攻击力的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 效果适用的条件：此卡被对方破坏并送去墓地
function c15092394.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 筛选可特殊召唤的「急袭猛禽」超量怪兽
function c15092394.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0xba) and not c:IsCode(15092394) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择自己墓地1只符合条件的「急袭猛禽」超量怪兽
function c15092394.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15092394.spfilter(chkc,e,tp) end
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「急袭猛禽」超量怪兽
		and Duel.IsExistingTarget(c15092394.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择自己墓地1只符合条件的「急袭猛禽」超量怪兽
	local g=Duel.SelectTarget(tp,c15092394.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将特殊召唤的怪兽加入处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息：将此卡加入处理对象（作为超量素材）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行效果处理：将目标怪兽特殊召唤，并将此卡叠放在其下方作为超量素材
function c15092394.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并执行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
			-- 将此卡叠放在特殊召唤的怪兽下方作为超量素材
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
