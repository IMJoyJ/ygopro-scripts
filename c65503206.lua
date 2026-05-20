--スクラップ・ソルジャー
-- 效果：
-- 场上表侧守备表示存在的这张卡被选择作为攻击对象的场合，战斗阶段结束时这张卡破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁士兵」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。把这张卡作为同调素材的场合，不是名字带有「废铁」的怪兽的同调召唤不能使用。
function c65503206.initial_effect(c)
	-- 场上表侧守备表示存在的这张卡被选择作为攻击对象的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetOperation(c65503206.regop)
	c:RegisterEffect(e1)
	-- 战斗阶段结束时这张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65503206,0))  --"这张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetTarget(c65503206.destg)
	e2:SetOperation(c65503206.desop)
	c:RegisterEffect(e2)
	-- 这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁士兵」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65503206,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c65503206.thcon)
	e3:SetTarget(c65503206.thtg)
	e3:SetOperation(c65503206.thop)
	c:RegisterEffect(e3)
	-- 把这张卡作为同调素材的场合，不是名字带有「废铁」的怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c65503206.synlimit)
	c:RegisterEffect(e2)
end
-- 判定这张卡是否为表侧守备表示，若是则注册一个在战斗阶段结束时重置的Flag，用于标记其被选择为了攻击对象
function c65503206.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDefensePos() and e:GetHandler():IsFaceup() then
		e:GetHandler():RegisterFlagEffect(65503206,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 自毁效果的靶子函数，检查自身是否带有被选择为攻击对象的Flag，并设置破坏自身的操作信息
function c65503206.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(65503206)~=0 end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 自毁效果的执行函数，若这张卡仍在场上则将其破坏
function c65503206.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判定回收效果的发动条件：这张卡因效果破坏送去墓地，且该效果的拥有者是名字带有「废铁」的卡
function c65503206.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re:GetOwner():IsSetCard(0x24)
end
-- 过滤出自己墓地中「废铁士兵」以外的名字带有「废铁」的怪兽，且该怪兽可以加入手卡
function c65503206.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(65503206) and c:IsAbleToHand()
end
-- 回收效果的靶子函数，检查墓地中是否存在合法的目标，并让玩家选择1只目标怪兽，设置回收的操作信息
function c65503206.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65503206.filter(chkc) end
	-- 检查自己墓地是否存在满足过滤条件的卡作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c65503206.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足过滤条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c65503206.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行函数，获取选中的目标，若其仍存在于墓地则将其加入手卡并向对方展示
function c65503206.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 限制同调素材的函数，若同调怪兽不是名字带有「废铁」的怪兽，则不能将这张卡作为同调素材
function c65503206.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x24)
end
