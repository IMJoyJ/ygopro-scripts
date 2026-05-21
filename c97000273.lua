--スクラップ・コング
-- 效果：
-- 这张卡召唤成功时，这张卡破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁金刚」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
function c97000273.initial_effect(c)
	-- 这张卡召唤成功时，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97000273,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c97000273.destg)
	e1:SetOperation(c97000273.desop)
	c:RegisterEffect(e1)
	-- 这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁金刚」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97000273,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c97000273.thcon)
	e2:SetTarget(c97000273.thtg)
	e2:SetOperation(c97000273.thop)
	c:RegisterEffect(e2)
end
-- 召唤成功时破坏效果的发动准备与操作信息设置
function c97000273.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 召唤成功时破坏效果的执行
function c97000273.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 检查此卡是否被名字带有「废铁」的卡的效果破坏并送去墓地
function c97000273.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 过滤墓地中「废铁金刚」以外的名字带有「废铁」的怪兽且能加入手牌
function c97000273.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(97000273) and c:IsAbleToHand()
end
-- 回收效果的发动准备，选择墓地中符合条件的怪兽作为对象
function c97000273.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97000273.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c97000273.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97000273.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为将目标卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行，将目标怪兽加入手牌并给对方确认
function c97000273.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
