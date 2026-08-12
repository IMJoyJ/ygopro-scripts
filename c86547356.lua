--インフェルニティ・パラノイア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只暗属性怪兽解放才能发动。从自己的卡组·墓地选和那只怪兽是卡名不同并是等级相同的1只「永火」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：把墓地的这张卡除外，以自己墓地1只「永火」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c86547356.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只暗属性怪兽解放才能发动。从自己的卡组·墓地选和那只怪兽是卡名不同并是等级相同的1只「永火」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86547356,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,86547356+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c86547356.cost)
	e1:SetTarget(c86547356.target)
	e1:SetOperation(c86547356.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「永火」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86547356,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置该效果在这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置该效果的发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86547356.thtg)
	e2:SetOperation(c86547356.thop)
	c:RegisterEffect(e2)
end
-- 效果1的发动代价处理函数，设置Label标记以在target中进行解放怪兽的检测
function c86547356.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0,0)
	return true
end
-- 过滤可解放的暗属性怪兽，且卡组或墓地存在与其卡名不同、等级相同的可特殊召唤的「永火」怪兽
function c86547356.costfilter(c,e,tp)
	-- 检查卡片是否为暗属性、等级1以上，且解放后能腾出怪兽区域，并且是自己场上的怪兽
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(1) and Duel.GetMZoneCount(tp,c)>0 and (c:IsFaceup() or c:IsControler(tp))
		-- 检查自己的卡组或墓地是否存在满足特殊召唤条件的「永火」怪兽
		and Duel.IsExistingMatchingCard(c86547356.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode(),c:GetLevel())
end
-- 过滤卡组或墓地中与被解放怪兽卡名不同、等级相同且可以特殊召唤的「永火」怪兽
function c86547356.spfilter(c,e,tp,code,lv)
	return c:IsSetCard(0xb) and not c:IsCode(code) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的发动准备与代价支付函数，检查并选择场上1只暗属性怪兽解放，记录其卡名和等级，并设置特殊召唤的操作信息
function c86547356.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local check,code,lv=e:GetLabel()
	if chk==0 then
		if check~=100 then return false end
		e:SetLabel(0,0,0)
		-- 检查自己场上是否存在至少1只满足解放过滤条件的怪兽
		return Duel.CheckReleaseGroup(tp,c86547356.costfilter,1,nil,e,tp)
	end
	-- 玩家选择1只满足条件的暗属性怪兽作为解放对象
	local tc=Duel.SelectReleaseGroup(tp,c86547356.costfilter,1,1,nil,e,tp):GetFirst()
	e:SetLabel(0,tc:GetCode(),tc:GetLevel())
	-- 将选中的怪兽解放作为发动代价
	Duel.Release(tc,REASON_COST)
	-- 设置当前连锁的操作信息为从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果1的效果处理函数，从卡组或墓地特殊召唤1只与解放怪兽卡名不同、等级相同的「永火」怪兽，并将其效果无效化
function c86547356.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local check,code,lv=e:GetLabel()
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或墓地选择1只满足条件的「永火」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86547356.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,code,lv)
	local tc=g:GetFirst()
	-- 若成功选出怪兽，则尝试将其以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 过滤墓地中可以加入手卡的「永火」怪兽
function c86547356.thfilter(c)
	return c:IsSetCard(0xb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果2的发动准备函数，选择自己墓地1只「永火」怪兽作为对象，并设置加入手卡的操作信息
function c86547356.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c86547356.thfilter(chkc) end
	-- 检查自己墓地是否存在可加入手卡的「永火」怪兽
	if chk==0 then return Duel.IsExistingTarget(c86547356.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「永火」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86547356.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果2的效果处理函数，将作为对象的墓地怪兽加入手卡
function c86547356.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
