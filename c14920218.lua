--賤竜の魔術師
-- 效果：
-- ←2 【灵摆】 2→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有「魔术师」卡存在的场合才能发动。从自己的额外卡组（表侧）把1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」怪兽为对象才能发动。那只怪兽加入手卡。
function c14920218.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「魔术师」卡存在的场合才能发动。从自己的额外卡组（表侧）把1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14920218,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,14920218)
	e2:SetCondition(c14920218.pcon)
	e2:SetTarget(c14920218.ptg)
	e2:SetOperation(c14920218.pop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤的场合，以自己墓地1只「贱龙之魔术师」以外的「魔术师」灵摆怪兽或「异色眼」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14920218,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,14920219)
	e3:SetTarget(c14920218.thtg)
	e3:SetOperation(c14920218.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 判断另一边的自己的灵摆区域是否存在「魔术师」卡
function c14920218.pcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的灵摆区域是否存在至少1张卡且该卡为「魔术师」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 定义灵摆效果中用于筛选额外卡组中符合条件的怪兽的过滤函数
function c14920218.pfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x98,0x99) and not c:IsCode(14920218) and c:IsAbleToHand()
end
-- 定义灵摆效果的目标设定函数
function c14920218.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足灵摆效果发动条件，即额外卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14920218.pfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理的卡为1张额外卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 定义灵摆效果的处理函数
function c14920218.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从额外卡组中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14920218.pfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义怪兽效果中用于筛选墓地符合条件的怪兽的过滤函数
function c14920218.thfilter(c)
	return c:IsType(TYPE_MONSTER) and ((c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)) or c:IsSetCard(0x99)) and not c:IsCode(14920218) and c:IsAbleToHand()
end
-- 定义怪兽效果的目标设定函数
function c14920218.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14920218.thfilter(chkc) end
	-- 检查是否满足怪兽效果发动条件，即墓地中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c14920218.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从墓地中选择1张符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c14920218.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要处理的卡为1张墓地中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义怪兽效果的处理函数
function c14920218.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
