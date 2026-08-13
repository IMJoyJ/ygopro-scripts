--運命の抱く爆弾
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。对方场上1只攻击力最高的怪兽破坏，给与对方那个原本攻击力数值的伤害。自己墓地没有「现世与冥界的逆转」存在的场合，再让自己受到和对方受到的伤害相同数值的伤害。
-- ②：这张卡从手卡·卡组送去墓地的场合，以自己墓地1只天使族·地属性·4星怪兽为对象才能发动。那只怪兽加入手卡。
function c51208877.initial_effect(c)
	-- aux.AddCodeList(c,17484499) 记录本卡效果中提到的另一张卡「现世与冥界的逆转」（卡号17484499），用于后续判断其是否存在
	aux.AddCodeList(c,17484499)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上1只攻击力最高的怪兽破坏，给与对方那个原本攻击力数值的伤害。自己墓地没有「现世与冥界的逆转」存在的场合，再让自己受到和对方受到的伤害相同数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,51208877)
	e1:SetCondition(c51208877.condition)
	e1:SetTarget(c51208877.target)
	e1:SetOperation(c51208877.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组送去墓地的场合，以自己墓地1只天使族·地属性·4星怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,51208878)
	e2:SetCondition(c51208877.thcon)
	e2:SetTarget(c51208877.thtg)
	e2:SetOperation(c51208877.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断：本卡只能在对方回合且对方怪兽攻击宣言时发动，这里检查当前回合玩家不是本卡控制者。
function c51208877.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是效果控制者 tp，即对方回合。
	return tp~=Duel.GetTurnPlayer()
end
-- 效果①的发动时处理：获取对方场上表侧表示怪兽，选出攻击力最高的怪兽作为破坏对象，并设置破坏与伤害的操作信息。
function c51208877.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 设置操作信息：将选出的攻击力最高的怪兽确定为破坏对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	local _,dam=tg:GetMaxGroup(Card.GetBaseAttack)
	if dam>0 then
		-- 设置操作信息：若攻击力最高怪兽的原本攻击力大于0，则给与对方与其原本攻击力数值相同的伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 效果①处理时：再次选择对方场上攻击力最高的怪兽（若并列则由发动者选1只）破坏；破坏成功则给对方造成该怪兽原本攻击力数值的伤害；若自己墓地没有「现世与冥界的逆转」，则自己受到相同伤害。
function c51208877.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		local dam=0
		if tg:GetCount()>1 then
			-- 在攻击力最高怪兽并列时，提示发动者选择要破坏的那1只怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 手动显示被选中破坏的怪兽的对象动画。
			Duel.HintSelection(sg)
			-- 若选中的怪兽被效果破坏成功，则获取其原本攻击力作为伤害数值。
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				dam=sg:GetFirst():GetBaseAttack()
			end
		else
			-- 若攻击力最高的怪兽只有1只且破坏成功，则获取其原本攻击力作为伤害数值。
			if Duel.Destroy(tg,REASON_EFFECT)>0 then
				dam=tg:GetFirst():GetBaseAttack()
			end
		end
		if dam>0 then
			-- 给对方造成与破坏怪兽原本攻击力等值的伤害。
			Duel.Damage(1-tp,dam,REASON_EFFECT)
			-- 检测自己墓地是否存在「现世与冥界的逆转」（卡号17484499）。
			if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) then
				-- 若自己墓地没有「现世与冥界的逆转」，则自己受到与对方受到的伤害相同数值的伤害。
				Duel.Damage(tp,dam,REASON_EFFECT)
			end
		end
	end
end
-- 效果②的发动条件判断：这张卡从手卡或卡组被送去墓地。
function c51208877.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的检索/对象筛选条件：选择自己墓地1只天使族·地属性·4星怪兽，且能被加入手卡。
function c51208877.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果②的发动时处理：取对象选择自己墓地符合条件的1只天使族·地属性·4星怪兽，并设置加入手卡的操作信息。
function c51208877.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51208877.thfilter(chkc) end
	-- 发动时确认自己墓地是否存在1只符合条件的对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51208877.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示发动者选择要加入手卡的那只怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的天使族·地属性·4星怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c51208877.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的怪兽加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理时：取得对象怪兽，若仍与效果关联，则将其加入手卡。
function c51208877.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
