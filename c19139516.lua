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
-- 被选为攻击对象时，若此卡为表侧守备表示，则给自己注册一个战斗阶段结束前有效的破坏标记，供战斗阶段结束时判定是否破坏此卡。
function c19139516.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDefensePos() and e:GetHandler():IsFaceup() then
		e:GetHandler():RegisterFlagEffect(19139516,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 破坏效果的发动条件判定：chk==0时，检查此卡是否带有之前注册的标记；若满足，则设置破坏此卡的操作信息。
function c19139516.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(19139516)~=0 end
	-- 设置本次连锁的操作信息：声明将要破坏的对象为此卡，数量为1，使系统识别该效果属于破坏分类。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若此卡仍与当前效果关联（未被移离或失效），则执行破坏。
function c19139516.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因将这张卡破坏并送去墓地。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 检索效果的诱发条件：此卡是被名字带有「废铁」的卡的效果破坏送去墓地（Reason同时含破坏与效果原因，且效果持有者为「废铁」字段的卡）。
function c19139516.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 检索的候选卡过滤器：满足「废铁」字段、是怪兽卡、不是「废铁兽」自身、且能够加入手牌。
function c19139516.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(19139516) and c:IsAbleToHand()
end
-- 检索效果的发动判定与目标选择：chk==0时确认存在合法对象；随后提示玩家选择1张符合条件的「废铁」怪兽，将其设为效果对象，并设置回手牌的操作信息。
function c19139516.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19139516.filter(chkc) end
	-- chk==0时检查自己墓地是否存在至少1张满足过滤条件且能成为效果对象的「废铁」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c19139516.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，让玩家选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由当前玩家从自己墓地选择1张符合条件的「废铁」怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c19139516.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果将把对象卡加入手牌（回手牌分类），对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时取得对象卡；若对象仍与效果关联，则将其加入持有者手牌，并向对方玩家展示该卡。
function c19139516.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁唯一的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入其持有者的手牌（nil表示回到原本持有者手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示被加入手牌的卡，以确认检索获得的是哪张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
