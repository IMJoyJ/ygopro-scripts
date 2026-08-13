--影霊衣の舞姫
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能对应「影灵衣」仪式魔法卡的发动把魔法·陷阱·怪兽的效果发动，对方不能把自己场上的「影灵衣」仪式怪兽作为效果的对象。
-- ②：这张卡被效果解放的场合，以「影灵衣舞姬」以外的自己的除外状态的1只「影灵衣」怪兽为对象才能发动。那只怪兽加入手卡。
function c52738610.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能对应「影灵衣」仪式魔法卡的发动把魔法·陷阱·怪兽的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c52738610.chainop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的「影灵衣」仪式怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c52738610.tgtg)
	-- 设置效果判定值：发动效果的玩家为本卡控制者（自己）时允许被选为对象，否则（对方发动效果）不能选择这些怪兽为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被效果解放的场合，以「影灵衣舞姬」以外的自己的除外状态的1只「影灵衣」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,52738610)
	e3:SetCondition(c52738610.thcon)
	e3:SetTarget(c52738610.thtg)
	e3:SetOperation(c52738610.thop)
	c:RegisterEffect(e3)
end
-- 连锁触发时检测：若当前发动的是「影灵衣」仪式魔法卡，则调用Duel.SetChainLimit设置连锁限制，阻止对方连锁该发动。
function c52738610.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0xb4) and re:IsActiveType(TYPE_RITUAL) then
		-- 为当前连锁设置连锁限制条件，让后续连锁是否允许加入由chainlm函数判定。
		Duel.SetChainLimit(c52738610.chainlm)
	end
end
-- 连锁限制判定：只有发动该「影灵衣」仪式魔法卡的玩家（tp）自己可以连锁，对方玩家不能连锁。
function c52738610.chainlm(e,rp,tp)
	return tp==rp
end
-- Target过滤：需要满足是「影灵衣」字段且为仪式怪兽的卡，这样才能作为该保护效果的对象。
function c52738610.tgtg(e,c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL)
end
-- 效果发动条件：这张卡被解放的原因必须包含“效果”（即因效果处理而解放）时才允许发动。
function c52738610.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 对象卡过滤条件：表侧表示、属于「影灵衣」字段的怪兽、不是这张卡自身（卡号52738610）、且可以被加入手卡。
function c52738610.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and not c:IsCode(52738610) and c:IsAbleToHand()
end
-- 发动时的目标选择：验证对象合法后，提示玩家从自己除外区选择1张符合条件的「影灵衣」怪兽作为对象，并登记操作信息。
function c52738610.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c52738610.thfilter(chkc) end
	-- 在发动判定时检查自己除外区是否存在至少1张符合条件的「影灵衣」怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c52738610.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给操作玩家显示选择提示信息，内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外区的符合条件的卡中选择1张作为效果对象，并自动将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c52738610.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：声明效果将要把对象卡加入手牌（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取得对象卡，若该卡仍与效果关联，则将其加入手卡并向对方展示。
function c52738610.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡，也就是之前选择的1只除外区「影灵衣」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去其持有者的手卡，即把该怪兽加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示这张刚刚加入手卡的卡，使对方确认信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
