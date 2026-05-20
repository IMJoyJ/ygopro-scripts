--ハイバネーション・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只4星以下的龙族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己场上没有连接怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只龙族·暗属性的连接怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c69109764.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己墓地1只4星以下的龙族怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69109764,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,69109764)
	e1:SetTarget(c69109764.thtg)
	e1:SetOperation(c69109764.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上没有连接怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只龙族·暗属性的连接怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69109764,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,69109765)
	e3:SetCondition(c69109764.spcon)
	-- 把墓地的这张卡除外作为发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c69109764.sptg)
	e3:SetOperation(c69109764.spop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地4星以下的龙族怪兽且能加入手卡
function c69109764.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择（检测墓地是否存在符合条件的怪兽，并选择为效果对象）
function c69109764.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c69109764.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的4星以下龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c69109764.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69109764.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理（将选择的对象怪兽加入手牌）
function c69109764.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的连接怪兽
function c69109764.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果②的发动条件（自己场上没有连接怪兽存在，且不在送去墓地的回合）
function c69109764.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上不存在表侧表示的连接怪兽，且当前回合不是该卡送去墓地的回合
	return not Duel.IsExistingMatchingCard(c69109764.cfilter,tp,LOCATION_MZONE,0,1,nil) and aux.exccon(e)
end
-- 过滤自己墓地龙族·暗属性的连接怪兽且能特殊召唤
function c69109764.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与目标选择（检测怪兽区域空位及墓地是否存在符合条件的怪兽，并选择为效果对象）
function c69109764.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c69109764.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足条件的龙族·暗属性连接怪兽
		and Duel.IsExistingTarget(c69109764.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69109764.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为：将选择的卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（将选择的对象怪兽特殊召唤）
function c69109764.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
