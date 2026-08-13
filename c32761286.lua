--スクラップ・ワーム
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡攻击的场合，战斗阶段结束时破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁蠕虫」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
function c32761286.initial_effect(c)
	-- 这张卡攻击的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c32761286.regop)
	c:RegisterEffect(e1)
	-- 战斗阶段结束时破坏。
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
-- 攻击宣言时给自身打上“本回合进行了攻击”的标记，以便在战斗阶段结束时判定是否需破坏自身，该标记到战斗阶段结束或离场等时重置。
function c32761286.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(32761286,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 作为战斗阶段结束时的必发诱发效果的发动条件判定，仅当本卡带有攻击宣言标记时才满足发动条件，并登记破坏自身的操作信息。
function c32761286.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(32761286)~=0 end
	-- 将“破坏这张卡”的操作信息写入当前连锁，使其他效果可以响应或确认。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理时，若本卡仍存在于场上且与该效果关联，则将其破坏。
function c32761286.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以卡片效果为破坏原因，将本卡破坏并送去墓地。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判定触发条件：本卡的破坏原因必须包含“被效果破坏”，且该破坏效果的发动者是名字带有「废铁」的怪兽；满足时检索效果才能发动。
function c32761286.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 定义可选择的检索目标：名字带有「废铁」的怪兽、不是本卡、位于墓地且能加入手卡。
function c32761286.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(32761286) and c:IsAbleToHand()
end
-- 效果发动时确认存在符合条件的对象，然后取对象地选择自己墓地1只符合条件的废铁怪兽，并登记将其加入手卡的操作信息。
function c32761286.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c32761286.filter(chkc) end
	-- 检查自己墓地是否存在至少1只可作为效果对象的符合条件的废铁怪兽。
	if chk==0 then return Duel.IsExistingTarget(c32761286.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要加入手牌的卡”的提示消息，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的废铁怪兽，并设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c32761286.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记将对象卡加入手卡的操作信息，供其他卡连锁时确认。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时取得对象卡，若其仍与效果关联，则将其加入持有者手卡，并向对方玩家确认这张卡。
function c32761286.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送入其持有者的手卡（nil 表示回到持有者手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
