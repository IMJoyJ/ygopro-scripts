--海晶乙女コーラルアネモネ
-- 效果：
-- 水属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只攻击力1500以下的水属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以「海晶少女 奶嘴海葵」以外的自己墓地1张「海晶少女」卡为对象才能发动。那张卡加入手卡。
function c79130389.initial_effect(c)
	-- 设置连接召唤手续：水属性怪兽2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,2)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只攻击力1500以下的水属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79130389,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,79130389)
	e1:SetTarget(c79130389.sptg)
	e1:SetOperation(c79130389.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以「海晶少女 奶嘴海葵」以外的自己墓地1张「海晶少女」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79130389,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,79130390)
	e2:SetCondition(c79130389.thcon)
	e2:SetTarget(c79130389.thtg)
	e2:SetOperation(c79130389.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中满足“水属性”、“攻击力1500以下”且能特殊召唤到此卡连接区的怪兽。
function c79130389.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAttackBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动准备与合法性检测（判定墓地是否存在符合条件的对象，并进行取对象操作）。
function c79130389.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79130389.spfilter(chkc,e,tp,zone) end
	-- 判定自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足特殊召唤条件的合法对象。
		and Duel.IsExistingTarget(c79130389.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的水属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c79130389.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置连锁处理的操作信息为“特殊召唤对象怪兽”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的运行空间（将对象怪兽在连接区特殊召唤，并适用“只能特殊召唤水属性怪兽”的誓约/限制）。
function c79130389.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽在作为这张卡所连接区的自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能特殊召唤。②：这张卡从场上送去墓地的场合，以「海晶少女 奶嘴海葵」以外的自己墓地1张「海晶少女」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c79130389.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“不能特殊召唤水属性以外的怪兽”的玩家限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤水属性怪兽（过滤非水属性怪兽）。
function c79130389.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 判定效果②的发动条件：此卡是否从场上送去墓地。
function c79130389.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己墓地中满足“「海晶少女」卡”、“非同名卡”且能加入手牌的卡。
function c79130389.thfilter(c)
	return c:IsSetCard(0x12b) and not c:IsCode(79130389) and c:IsAbleToHand()
end
-- 效果②的发动准备与合法性检测（判定墓地是否存在符合条件的对象，并进行取对象操作）。
function c79130389.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79130389.thfilter(chkc) end
	-- 判定自己墓地是否存在满足回收条件的合法对象。
	if chk==0 then return Duel.IsExistingTarget(c79130389.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「海晶少女」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c79130389.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理的操作信息为“将对象卡加入手牌”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的运行空间（将选择的对象卡加入手牌）。
function c79130389.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入玩家手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
