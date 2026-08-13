--RR－エトランゼ・ファルコン
-- 效果：
-- 5星怪兽×2
-- ①：这张卡有超量怪兽在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
-- ②：这张卡被对方破坏送去墓地的场合，以「急袭猛禽-异邦猎鹰」以外的自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡在那张卡下面重叠作为超量素材。
function c15092394.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加超量召唤手续：将等级5的任意怪兽2只叠放作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,5,2)
	-- ①：这张卡有超量怪兽在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力数值的伤害。
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
	-- ②：这张卡被对方破坏送去墓地的场合，以「急袭猛禽-异邦猎鹰」以外的自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡在那张卡下面重叠作为超量素材。
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
-- 效果①的发动条件：检查这张卡的超量素材中是否存在至少1只超量怪兽（即这张卡持有超量怪兽作为超量素材）。
function c15092394.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
-- 效果①的发动代价：检查并实际将这张卡的1个超量素材取除作为发动代价。
function c15092394.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的发动时处理：以对方场上1只怪兽为对象取对象，选择怪兽后设置破坏该怪兽并造成其原本攻击力伤害的操作信息。
function c15092394.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 发动合法性检查：确认对方场上存在至少1只可以成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示消息，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将所选择的1只怪兽登记为将要被破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：将向对方玩家造成该对象怪兽原本攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 效果①处理：取得对象怪兽，若其仍与效果关联则将其破坏；若破坏成功，给予对方该怪兽原本攻击力数值的伤害。
function c15092394.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，然后将其破坏；若破坏成功（返回值不为0）才继续处理后续效果。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给予对方玩家对象怪兽原本攻击力数值的伤害。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡的原本控制者是发动者，且被对方玩家（某些效果/卡）破坏并送去墓地。
function c15092394.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 效果②可选对象的筛选条件：自己墓地中「急袭猛禽」超量怪兽，且不是「急袭猛禽-异邦猎鹰」本身，并可以被特殊召唤。
function c15092394.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0xba) and not c:IsCode(15092394) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时处理：确认我方主要怪兽区有空位且墓地存在符合条件的对象，选择1只符合条件的墓地超量怪兽为对象，并设置特殊召唤及这张卡离墓的操作信息。
function c15092394.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15092394.spfilter(chkc,e,tp) end
	-- 检查我方主要怪兽区是否存在空位，以准备特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只满足条件的「急袭猛禽」超量怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c15092394.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 给玩家显示选择提示消息，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「急袭猛禽」超量怪兽作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c15092394.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将所选择的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：这张卡将离开墓地（用于和涉及墓地的效果交互，如王家长眠之谷）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②处理：先确认场上仍有空位，取得对象怪兽；若其与效果关联则将其表侧表示特殊召唤；特殊召唤成功后，若这张卡仍与效果关联且对象怪兽不免疫此效果、这张卡可以叠放，则将这张卡叠放在对象怪兽下方作为超量素材。
function c15092394.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认我方主要怪兽区有空格；若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，然后将其以表侧表示特殊召唤；若特殊召唤成功则进入后续叠放处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		if c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsCanOverlay() then
			-- 将这张卡重叠在对象怪兽下面，作为其超量素材。
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
	-- 完成特殊召唤的流程，触发特殊召唤成功等相关时点。
	Duel.SpecialSummonComplete()
end
