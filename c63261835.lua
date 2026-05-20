--ハーピィ・レディ・SC
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤的场合，可以把自己场上1只「鹰身」怪兽当作调整使用。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：魔法·陷阱卡的效果发动时，以对方场上1只怪兽或者自己场上1只「鹰身」怪兽为对象才能发动。那只怪兽回到手卡。
function c63261835.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，允许使用1只「鹰身」怪兽当作调整使用，以及1只以上的非调整怪兽
	aux.AddSynchroMixProcedure(c,c63261835.matfilter1,nil,nil,aux.NonTuner(nil),1,99)
	-- 使这张卡在场上·墓地存在时，卡名当作「鹰身女郎」使用
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：魔法·陷阱卡的效果发动时，以对方场上1只怪兽或者自己场上1只「鹰身」怪兽为对象才能发动。那只怪兽回到手卡。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63261835,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,63261835)
	e2:SetCondition(c63261835.thcon)
	e2:SetTarget(c63261835.thtg)
	e2:SetOperation(c63261835.thop)
	c:RegisterEffect(e2)
end
-- 过滤同调素材：必须是调整怪兽，或者是「鹰身」怪兽（当作调整使用）
function c63261835.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsSetCard(0x64)
end
-- 效果发动的条件：魔法·陷阱卡的效果发动时
function c63261835.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤可作为对象的目标：对方场上的怪兽，或者自己场上表侧表示的「鹰身」怪兽，且必须能回到手牌
function c63261835.thfilter(c,tp)
	return (c:IsControler(1-tp) or (c:IsFaceup() and c:IsSetCard(0x64))) and c:IsAbleToHand()
end
-- 效果发动的目标选择与处理信息设置
function c63261835.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63261835.thfilter(chkc,tp) end
	-- 检查场上是否存在至少1只满足条件的可选为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c63261835.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63261835.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息：将选中的1只怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽送回手牌
function c63261835.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽因效果送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
