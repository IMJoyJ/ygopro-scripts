--スクラップ・ワーム
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡攻击的场合，战斗阶段结束时破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁蠕虫」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
function c32761286.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c32761286.regop)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，战斗阶段结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32761286,0))  --"这张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetTarget(c32761286.destg)
	e2:SetOperation(c32761286.desop)
	c:RegisterEffect(e2)
	-- 这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁蠕虫」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32761286,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c32761286.thcon)
	e3:SetTarget(c32761286.thtg)
	e3:SetOperation(c32761286.thop)
	c:RegisterEffect(e3)
	-- 这张卡可以直接攻击对方玩家。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
end
-- 记录攻击宣言标志位，用于后续判断是否需要在战斗阶段结束时破坏此卡。
function c32761286.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(32761286,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判断是否在战斗阶段结束时需要破坏此卡。
function c32761286.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(32761286)~=0 end
	-- 设置操作信息为破坏此卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行破坏此卡的操作。
function c32761286.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断此卡是否因名字带有「废铁」的卡的效果而被破坏并送去墓地。
function c32761286.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 筛选墓地里名字带有「废铁」且不是废铁蠕虫的怪兽。
function c32761286.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(32761286) and c:IsAbleToHand()
end
-- 设置检索效果的目标为墓地里符合条件的怪兽。
function c32761286.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32761286.filter(chkc) end
	-- 判断是否存在符合条件的墓地怪兽作为检索目标。
	if chk==0 then return Duel.IsExistingTarget(c32761286.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地里符合条件的1只怪兽作为检索目标。
	local g=Duel.SelectTarget(tp,c32761286.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将目标怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将目标怪兽加入手牌的操作。
function c32761286.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽加入手牌。
		Duel.ConfirmCards(1-tp,tc)
	end
end
