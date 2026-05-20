--ワルキューレ・アルテスト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用魔法卡的效果从手卡特殊召唤成功的场合，以自己墓地1张「时间女神的恶作剧」为对象才能发动。那张卡加入手卡。
-- ②：自己场上有「女武神长女」以外的「女武神」怪兽存在的场合才能发动。从对方墓地选1只怪兽除外。那之后，这张卡的攻击力直到回合结束时变成和除外的怪兽的原本攻击力相同。这个效果在对方回合也能发动。
function c66809920.initial_effect(c)
	-- ①：这张卡用魔法卡的效果从手卡特殊召唤成功的场合，以自己墓地1张「时间女神的恶作剧」为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66809920,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,66809920)
	e1:SetCondition(c66809920.thcon)
	e1:SetTarget(c66809920.thtg)
	e1:SetOperation(c66809920.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「女武神长女」以外的「女武神」怪兽存在的场合才能发动。从对方墓地选1只怪兽除外。那之后，这张卡的攻击力直到回合结束时变成和除外的怪兽的原本攻击力相同。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66809920,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66809921)
	e2:SetCondition(c66809920.rmcon)
	e2:SetTarget(c66809920.rmtg)
	e2:SetOperation(c66809920.rmop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否由魔法卡的效果从手卡特殊召唤成功
function c66809920.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and c:IsPreviousLocation(LOCATION_HAND)
end
-- 过滤自己墓地中卡名为「时间女神的恶作剧」且能加入手牌的卡片
function c66809920.thfilter(c)
	return c:IsCode(92182447) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查并选择自己墓地的一张「时间女神的恶作剧」作为对象，并设置操作信息
function c66809920.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66809920.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的「时间女神的恶作剧」
	if chk==0 then return Duel.IsExistingTarget(c66809920.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地的一张「时间女神的恶作剧」作为效果对象
	local g=Duel.SelectTarget(tp,c66809920.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的「时间女神的恶作剧」加入手牌
function c66809920.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示存在的、「女武神长女」以外的「女武神」怪兽
function c66809920.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122) and not c:IsCode(66809920)
end
-- 效果②的发动条件：自己场上存在「女武神长女」以外的「女武神」怪兽
function c66809920.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除「女武神长女」以外的表侧表示「女武神」怪兽
	return Duel.IsExistingMatchingCard(c66809920.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤对方墓地中可以被除外的怪兽卡
function c66809920.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果②的发动准备：检查对方墓地是否存在可除外的怪兽，并设置除外操作信息
function c66809920.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66809920.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置效果处理信息：将对方墓地的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：将对方墓地1只怪兽除外，并使这张卡的攻击力直到回合结束时变成和除外怪兽的原本攻击力相同
function c66809920.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家选择对方墓地的一只怪兽
	local rc=Duel.SelectMatchingCard(tp,c66809920.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()
	if rc then
		-- 若成功将选中的怪兽因效果表侧表示除外，且此卡在场上表侧表示存在
		if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 中断当前效果处理，使后续的攻击力变化处理不与除外同时进行
			Duel.BreakEffect()
			local atk=rc:GetBaseAttack()
			-- 那之后，这张卡的攻击力直到回合结束时变成和除外的怪兽的原本攻击力相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
