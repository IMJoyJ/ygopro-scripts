--青き眼の祭司
-- 效果：
-- 「青色眼睛的祭司」的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只光属性·1星调整为对象才能发动。那只怪兽加入手卡。
-- ②：让墓地的这张卡回到卡组，以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从自己墓地选那只怪兽以外的1只「青眼」怪兽特殊召唤。
function c45644898.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只光属性·1星调整为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45644898,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45644898.target)
	e1:SetOperation(c45644898.operation)
	c:RegisterEffect(e1)
	-- 「青色眼睛的祭司」的②的效果1回合只能使用1次。②：让墓地的这张卡回到卡组，以自己场上1只效果怪兽为对象才能发动。那只怪兽送去墓地，从自己墓地选那只怪兽以外的1只「青眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45644898,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,45644898)
	e2:SetCost(c45644898.spcost)
	e2:SetTarget(c45644898.sptg)
	e2:SetOperation(c45644898.spop)
	c:RegisterEffect(e2)
end
-- 定义①效果的检索/对象过滤条件：自己墓地的光属性·1星调整怪兽，且能被效果加入手卡。
function c45644898.thfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1) and c:IsAbleToHand()
end
-- ①效果的发动目标选择处理：确认墓地存在满足条件的光属性·1星调整，让玩家选择1只作为对象，并登记加入手卡的操作信息。
function c45644898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45644898.thfilter(chkc) end
	-- 效果发动合法性检查：自己墓地是否存在至少1只满足thfilter条件且能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c45644898.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地的满足条件的怪兽中选择1只作为效果对象，并自动与该连锁建立联系。
	local g=Duel.SelectTarget(tp,c45644898.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次效果将执行“加入手卡”的操作，对象为已选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理时，取得对象并确认其仍与效果关联后，将那只怪兽加入持有者手卡。
function c45644898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者的手卡（处理原因为效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动代价：将墓地的这张卡回到卡组并洗牌，作为发动代价。
function c45644898.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将墓地的这张卡弹回持有者卡组并洗牌，作为②效果的发动代价。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义②效果取对象的过滤条件：自己场上表侧表示的效果怪兽，且可以被送去墓地。
function c45644898.gvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
-- 定义特殊召唤对象的过滤条件：墓地中的「青眼」字段怪兽，且可以被本次效果特殊召唤。
function c45644898.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与取对象处理：以自己场上1只效果怪兽为对象，同时确认有特殊召唤可能，选择对象并登记送墓和特殊召唤的操作信息。
function c45644898.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45644898.gvfilter(chkc) end
	-- 效果发动合法性检查：自己场上是否存在至少1只满足gvfilter条件的效果怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c45644898.gvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 宽松检查自己主要怪兽区域是否存在可用空位（因对象会先送墓，处理时可能腾出位置，故发动时只要不是被完全锁死即可）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己墓地是否存在至少1只满足spfilter条件且可以被特殊召唤的「青眼」怪兽。
		and Duel.IsExistingMatchingCard(c45644898.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示“请选择要送去墓地的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上的表侧效果怪兽中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,c45644898.gvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记本次效果将执行“送去墓地”的操作，对象为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 登记本次效果后续将执行“特殊召唤”的操作，特殊召唤对象从墓地中选出，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理时，先将对象怪兽送去墓地；若成功且仍在墓地，再从自己墓地选择1只「青眼」怪兽特殊召唤。
function c45644898.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 将对象怪兽送去墓地；若实际送入成功且该卡现在位于墓地，才继续后续处理。
		and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 特殊召唤前确认自己主要怪兽区域存在可用的空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只满足spfilter且不受王家长眠之谷影响的「青眼」怪兽，排除已送墓的对象，作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45644898.spfilter),tp,LOCATION_GRAVE,0,1,1,tc,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「青眼」怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区域。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
