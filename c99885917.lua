--海晶乙女パスカルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「海晶少女 紫红拟花鮨」以外的1只「海晶少女」怪兽守备表示特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「海晶少女」魔法·陷阱卡为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c99885917.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「海晶少女 紫红拟花鮨」以外的1只「海晶少女」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99885917,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,99885917)
	e1:SetTarget(c99885917.sptg)
	e1:SetOperation(c99885917.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地1张「海晶少女」魔法·陷阱卡为对象才能发动。那张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99885917,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,99885918)
	-- 设置效果发动条件：此效果不能在这张卡被送去墓地的回合发动（通过aux.exccon标准条件实现）。
	e3:SetCondition(aux.exccon)
	-- 设置效果的发动代价：将这张卡自身从墓地除外（由aux.bfgcost完成，若可除外则作为代价除外）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c99885917.thtg)
	e3:SetOperation(c99885917.thop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤的过滤函数：筛选持有「海晶少女」字段（0x12b）、不是卡名「海晶少女 紫红拟花鮨」自身、且能够以表侧守备表示被特殊召唤的怪兽。
function c99885917.spfilter(c,e,tp)
	return c:IsSetCard(0x12b) and not c:IsCode(99885917) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动条件判定：在发动时确认主要怪兽区有空格且手牌存在满足spfilter条件的「海晶少女」怪兽。
function c99885917.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己主要怪兽区仍有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检测：确认手牌中存在至少1张满足spfilter过滤条件的「海晶少女」怪兽。
		and Duel.IsExistingMatchingCard(c99885917.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果将从手牌把1只怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON），便于连锁判定与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①处理：先确认主要怪兽区仍有空格，然后提示玩家从手牌选择1只符合条件的「海晶少女」怪兽，并以表侧守备表示特殊召唤。
function c99885917.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次检查：若主要怪兽区没有空格，则直接终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示提示信息：请选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足spfilter过滤条件的「海晶少女」怪兽。
	local g=Duel.SelectMatchingCard(tp,c99885917.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义回收过滤函数：筛选「海晶少女」字段的魔法·陷阱卡，且该卡能够被加入手牌。
function c99885917.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动处理：若chkc传入则校验该对象在墓地、属于自己且满足thfilter；发动检测时确认存在合法对象后，提示玩家选择1张「海晶少女」魔法·陷阱卡作为对象，并设置回手操作信息。
function c99885917.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99885917.thfilter(chkc) end
	-- 发动条件检测：确认自己墓地存在至少1张符合条件的「海晶少女」魔法·陷阱卡且可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c99885917.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示提示信息：请选择要加入手牌的卡（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1张符合条件的「海晶少女」魔法·陷阱卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c99885917.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：声明本效果将对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理：取得效果对象；若对象仍与该效果有关，则将其加入持有者手牌。
function c99885917.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时的效果对象卡（此效果只取1个对象，所以用Duel.GetFirstTarget）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
