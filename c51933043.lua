--RR－ヒール・イーグル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有「急袭猛禽」怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「急袭猛禽」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c51933043.initial_effect(c)
	-- ①：自己场上的怪兽只有「急袭猛禽」怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51933043,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51933043)
	e1:SetCondition(c51933043.sscon)
	e1:SetTarget(c51933043.sstg)
	e1:SetOperation(c51933043.ssop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「急袭猛禽」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51933044)
	-- 设置②效果的发动代价：将墓地中的这张卡除外（作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51933043.thtg)
	e2:SetOperation(c51933043.thop)
	c:RegisterEffect(e2)
end
-- 定义“不符合①发动条件的怪兽”：不是「急袭猛禽」怪兽，或者处于里侧表示的怪兽。
function c51933043.ssfilter(c)
	return not c:IsSetCard(0xba) or c:IsFacedown()
end
-- ①效果的发动条件判定：自己场上存在怪兽，且场上不存在任何非「急袭猛禽」或里侧表示的怪兽，即自己场上的怪兽全部为表侧表示且都是「急袭猛禽」怪兽。
function c51933043.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- ①效果条件之一：自己场上存在怪兽（主要怪兽区有怪兽）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- ①效果条件之二：场上不存在“不是急袭猛禽或里侧表示”的怪兽，即自己场上的怪兽均为表侧表示的「急袭猛禽」怪兽。
		and not Duel.IsExistingMatchingCard(c51933043.ssfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动目标检查/操作设置函数：在chk==0（合法性检查）时，确认自己主要怪兽区有空位且这张卡可以被特殊召唤；若通过，则设置后续特殊召唤的操作信息。
function c51933043.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动合法性检查：自己主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将把这张卡特殊召唤，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理函数：若这张卡仍与发动时的效果关联，则将这张卡表侧表示特殊召唤到自己场上。
function c51933043.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示（POS_FACEUP，表侧攻击表示）特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义②效果可选对象：自己墓地的「急袭猛禽」魔法·陷阱卡，且该卡能够加入手卡。
function c51933043.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- ②效果的发动目标选择函数：取对象时，对象只能是自己墓地符合条件的「急袭猛禽」魔法·陷阱卡；发动时检查存在至少1张可选对象；随后让玩家选择1张作为对象，并设置加入手卡的操作信息。
function c51933043.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51933043.thfilter(chkc) end
	-- ②效果发动合法性检查：自己墓地是否存在至少1张符合条件的「急袭猛禽」魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c51933043.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向操作玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地中选出1张符合条件的「急袭猛禽」魔法·陷阱卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c51933043.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果将把选择的对象卡加入手卡，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理函数：取得②效果的对象卡，若该对象仍与效果关联，则将其加入持有者的手卡。
function c51933043.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因（REASON_EFFECT）送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
