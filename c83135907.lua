--スクラップ・ゴブリン
-- 效果：
-- 场上表侧守备表示存在的这张卡被选择作为攻击对象的场合，战斗阶段结束时这张卡破坏。这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁哥布林」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。此外，这张卡不会被战斗破坏。
function c83135907.initial_effect(c)
	-- 场上表侧守备表示存在的这张卡被选择作为攻击对象的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetOperation(c83135907.regop)
	c:RegisterEffect(e1)
	-- 战斗阶段结束时这张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83135907,0))  --"这张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetTarget(c83135907.destg)
	e2:SetOperation(c83135907.desop)
	c:RegisterEffect(e2)
	-- 这张卡被名字带有「废铁」的卡的效果破坏送去墓地的场合，可以选择「废铁哥布林」以外的自己墓地存在的1只名字带有「废铁」的怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(83135907,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c83135907.thcon)
	e3:SetTarget(c83135907.thtg)
	e3:SetOperation(c83135907.thop)
	c:RegisterEffect(e3)
	-- 此外，这张卡不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 被选择作为攻击对象时，若自身呈表侧守备表示，则给自身注册一个在战斗阶段结束前有效的Flag
function c83135907.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDefensePos() and e:GetHandler():IsFaceup() then
		e:GetHandler():RegisterFlagEffect(83135907,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 战斗阶段结束时自毁效果的Target函数，确认自身是否带有被攻击的Flag，并设置破坏自身的操作信息
function c83135907.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(83135907)~=0 end
	-- 设置当前连锁的操作信息为：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 战斗阶段结束时自毁效果的Operation函数，若自身仍在场则将其破坏
function c83135907.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 回收效果的发动条件：自身因效果破坏送去墓地，且该效果的来源卡片属于「废铁」系列
function c83135907.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetReason(),0x41)==0x41 and re and re:GetOwner():IsSetCard(0x24)
end
-- 过滤条件：自己墓地中「废铁哥布林」以外的「废铁」怪兽，且能加入手牌
function c83135907.filter(c)
	return c:IsSetCard(0x24) and c:IsType(TYPE_MONSTER) and not c:IsCode(83135907) and c:IsAbleToHand()
end
-- 回收效果的Target函数，选择自己墓地1只符合条件的「废铁」怪兽作为对象，并设置回收的操作信息
function c83135907.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83135907.filter(chkc) end
	-- 在发动效果时，检测自己墓地是否存在符合条件的「废铁」怪兽
	if chk==0 then return Duel.IsExistingTarget(c83135907.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家提示：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「废铁」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83135907.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的Operation函数，将选中的对象怪兽加入手牌并给对方确认
function c83135907.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
