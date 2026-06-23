--スクラップ・ビースト
-- 效果：
-- 场上表侧守备表示存在的这张卡被选择作为攻击对象的场合，战斗阶段结束时这张卡破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁兽」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
function c19139516.initial_effect(c)
	-- 场上表侧守备表示存在的这张卡被选择作为攻击对象的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetOperation(c19139516.regop)
	c:RegisterEffect(e1)
	-- 战斗阶段结束时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19139516,0))  --"这张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetTarget(c19139516.destg)
	e2:SetOperation(c19139516.desop)
	c:RegisterEffect(e2)
	-- 这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁兽」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19139516,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c19139516.thcon)
	e3:SetTarget(c19139516.thtg)
	e3:SetOperation(c19139516.thop)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否为表侧守备表示，若是则给这张卡注册一个在战斗阶段结束前有效的标记。
function c19139516.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDefensePos() and e:GetHandler():IsFaceup() then
		e:GetHandler():RegisterFlagEffect(19139516,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 检查这张卡是否带有被攻击的标记，并设置破坏自身的操作信息。
function c19139516.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(19139516)~=0 end
	-- 设置当前连锁的操作信息为破坏这张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 若这张卡仍在场，则将其破坏。
function c19139516.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡因效果破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 检查这张卡是否因“废铁”卡片的效果被破坏并送去墓地。
function c19139516.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 过滤出墓地中除“废铁兽”以外的“废铁”怪兽。
function c19139516.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(19139516) and c:IsAbleToHand()
end
-- 检查墓地是否存在合法的目标，并让玩家选择一个目标，设置加入手牌的操作信息。
function c19139516.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19139516.filter(chkc) end
	-- 发动检查：检查自己墓地是否存在满足条件的卡片。
	if chk==0 then return Duel.IsExistingTarget(c19139516.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在界面上显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择墓地中1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c19139516.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡片加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理，将选中的对象卡片加入手牌并给对方确认。
function c19139516.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
