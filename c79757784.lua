--幻奏の音女タムタム
-- 效果：
-- ①：自己场上有「幻奏」怪兽存在，这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合，以自己场上1只「幻奏」怪兽为对象才能发动。那只怪兽的攻击力下降500，给与对方500伤害。
function c79757784.initial_effect(c)
	-- ①：自己场上有「幻奏」怪兽存在，这张卡特殊召唤成功的场合才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(c79757784.thcon)
	e1:SetTarget(c79757784.thtg)
	e1:SetOperation(c79757784.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合，以自己场上1只「幻奏」怪兽为对象才能发动。那只怪兽的攻击力下降500，给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c79757784.damcon)
	e2:SetTarget(c79757784.damtg)
	e2:SetOperation(c79757784.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数：自己场上表侧表示的「幻奏」怪兽
function c79757784.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 发动条件：自己场上存在自身以外的表侧表示的「幻奏」怪兽
function c79757784.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在自身以外的表侧表示的「幻奏」怪兽
	return Duel.IsExistingMatchingCard(c79757784.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：卡组或墓地中可以加入手牌的「融合」
function c79757784.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果目标：检查卡组或墓地中是否存在「融合」，并设置将选中的卡加入手牌的操作信息
function c79757784.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在可以加入手牌的的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c79757784.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置将卡组或墓地的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从卡组或墓地选择1张「融合」加入手牌并给对方确认
function c79757784.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张符合条件的「融合」（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c79757784.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 发动条件：这张卡作为融合召唤的素材送去墓地
function c79757784.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_FUSION and c:IsLocation(LOCATION_GRAVE) and not c:IsReason(REASON_RETURN)
end
-- 过滤函数：自己场上表侧表示且攻击力在500以上的「幻奏」怪兽
function c79757784.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b) and c:IsAttackAbove(500)
end
-- 效果目标：选择自己场上1只「幻奏」怪兽作为对象，设置造成500伤害的操作信息
function c79757784.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79757784.atkfilter(chkc) end
	-- 检查自己场上是否存在符合对象条件的「幻奏」怪兽
	if chk==0 then return Duel.IsExistingTarget(c79757784.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示且攻击力在500以上的「幻奏」怪兽作为效果的对象
	Duel.SelectTarget(tp,c79757784.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置给与对方500点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：使对象怪兽的攻击力下降500，并给与对方500伤害
function c79757784.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力下降500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 给与对方500点伤害
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
