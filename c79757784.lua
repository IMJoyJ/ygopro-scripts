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
-- 过滤条件：场上表侧表示的「幻奏」怪兽
function c79757784.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 效果①的发动条件：自己场上有除自身以外的「幻奏」怪兽存在
function c79757784.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的表侧表示「幻奏」怪兽
	return Duel.IsExistingMatchingCard(c79757784.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件：卡名是「融合」且能加入手卡
function c79757784.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查卡组或墓地是否存在「融合」并设置操作信息
function c79757784.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己的卡组或墓地是否存在可以加入手卡的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c79757784.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的效果处理：从卡组或墓地将1张「融合」加入手卡
function c79757784.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「融合」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c79757784.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：作为融合召唤的素材送去墓地
function c79757784.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_FUSION and c:IsLocation(LOCATION_GRAVE) and not c:IsReason(REASON_RETURN)
end
-- 过滤条件：自己场上表侧表示、攻击力在500以上且是「幻奏」的怪兽
function c79757784.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b) and c:IsAttackAbove(500)
end
-- 效果②的发动准备：选择自己场上1只「幻奏」怪兽为对象并设置伤害操作信息
function c79757784.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79757784.atkfilter(chkc) end
	-- 在发动阶段，检查自己场上是否存在满足条件的「幻奏」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c79757784.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只满足条件的「幻奏」怪兽作为效果对象
	Duel.SelectTarget(tp,c79757784.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理的操作信息为：给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果②的效果处理：使对象怪兽攻击力下降500，并给与对方500伤害
function c79757784.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
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
			-- 给与对方玩家500点效果伤害
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
	end
end
