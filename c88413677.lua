--ドヨン＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合，以自己墓地1张「“艾”」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c88413677.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88413677,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,88413677)
	e1:SetTarget(c88413677.thtg1)
	e1:SetOperation(c88413677.thop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合，以自己墓地1张「“艾”」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88413677,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,88413678)
	e3:SetCondition(c88413677.thcon2)
	e3:SetTarget(c88413677.thtg2)
	e3:SetOperation(c88413677.thop2)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中满足「@火灵天星」怪兽且能加入手卡的卡片
function c88413677.thfilter1(c)
	return c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择（检查墓地是否存在符合条件的「@火灵天星」怪兽，并进行取对象选择）
function c88413677.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88413677.thfilter1(chkc) end
	-- 检查自己墓地是否存在至少1只可以加入手卡的「@火灵天星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c88413677.thfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「@火灵天星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88413677.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，该效果的操作分类为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理（将作为对象的「@火灵天星」怪兽加入手牌）
function c88413677.thop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 检查发动条件：此卡作为连接素材送去墓地，且该连接怪兽是电子界族
function c88413677.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_LINK and c:GetReasonCard():IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_GRAVE)
end
-- 过滤自己墓地中满足「“艾”」魔法·陷阱卡且能加入手卡的卡片
function c88413677.thfilter2(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择（检查墓地是否存在符合条件的「“艾”」魔法·陷阱卡，并进行取对象选择）
function c88413677.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c88413677.thfilter2(chkc) end
	-- 检查自己墓地是否存在至少1张可以加入手卡的「“艾”」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c88413677.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「“艾”」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c88413677.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，该效果的操作分类为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理（将作为对象的「“艾”」魔法·陷阱卡加入手牌）
function c88413677.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标魔法·陷阱卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
