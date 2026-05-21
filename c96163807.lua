--冥界騎士トリスタン
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只守备力0的不死族怪兽为对象才能发动。那张卡加入手卡。
-- ②：自己场上有这张卡以外的不死族怪兽存在的场合，这张卡的攻击力上升300。
function c96163807.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只守备力0的不死族怪兽为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c96163807.thtg)
	e1:SetOperation(c96163807.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上有这张卡以外的不死族怪兽存在的场合，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c96163807.atkcon)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 过滤守备力为0、可以加入手牌的不死族怪兽
function c96163807.thfilter(c)
	return c:IsDefense(0) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择，检测墓地是否存在符合条件的怪兽并选择对象
function c96163807.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96163807.thfilter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c96163807.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向发动玩家发送提示信息，要求选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地中1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96163807.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表明此效果会将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理函数，将选中的对象怪兽加入手牌
function c96163807.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的不死族怪兽
function c96163807.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 效果②的条件函数，判断自己场上是否存在除自身以外的不死族怪兽
function c96163807.atkcon(e)
	-- 检查自己场上是否存在除自身以外的表侧表示不死族怪兽
	return Duel.IsExistingMatchingCard(c96163807.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
