--ラヴァル・ランスロッド
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡在结束阶段时送去墓地。场上存在的这张卡被破坏送去墓地时，可以选择从游戏中除外的1只自己的炎属性怪兽加入手卡。
function c123709.initial_effect(c)
	-- 这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(123709,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c123709.ntcon)
	e1:SetOperation(c123709.ntop)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被破坏送去墓地时，可以选择从游戏中除外的1只自己的炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(123709,2))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c123709.condition)
	e2:SetTarget(c123709.target)
	e2:SetOperation(c123709.operation)
	c:RegisterEffect(e2)
end
-- 判断召唤是否满足条件，即不需解放且等级不低于5且场上存在空位。
function c123709.ntcon(e,c,minc)
	if c==nil then return true end
	-- 返回是否满足不需解放召唤的条件。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 执行不需解放召唤后的处理，即在结束阶段将此卡送去墓地。
function c123709.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 在结束阶段时将此卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(123709,1))  --"这张卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c123709.tgcon)
	e1:SetTarget(c123709.tgtg)
	e1:SetOperation(c123709.tgop)
	e1:SetReset(RESET_EVENT+0xee0000)
	c:RegisterEffect(e1)
end
-- 判断是否为结束阶段的处理条件。
function c123709.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家的结束阶段。
	return tp==Duel.GetTurnPlayer()
end
-- 设置结束阶段将此卡送去墓地的效果目标。
function c123709.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将此卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 执行将此卡送去墓地的操作。
function c123709.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 判断此卡是否因破坏而送去墓地且之前在场上。
function c123709.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤符合条件的除外区炎属性怪兽。
function c123709.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置选择除外区炎属性怪兽的效果目标。
function c123709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c123709.filter(chkc) end
	-- 判断是否存在符合条件的除外区炎属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c123709.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示选择将怪兽加入手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择一个符合条件的除外区炎属性怪兽。
	local g=Duel.SelectTarget(tp,c123709.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置将选中的怪兽加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将除外区炎属性怪兽加入手卡的操作。
function c123709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_FIRE) then
		-- 将目标怪兽以效果原因加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
