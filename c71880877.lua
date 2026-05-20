--SDロボ・モンキ
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。此外，1回合1次，把自己墓地1只机械族怪兽从游戏中除外才能发动。从自己墓地选择1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」加入手卡。
function c71880877.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71880877,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c71880877.sumtg)
	e1:SetOperation(c71880877.sumop)
	c:RegisterEffect(e1)
	-- 1回合1次，把自己墓地1只机械族怪兽从游戏中除外才能发动。从自己墓地选择1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71880877,1))  --"加入收卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c71880877.thcost)
	e2:SetTarget(c71880877.thtg)
	e2:SetOperation(c71880877.thop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可以特殊召唤的「超级防卫机器人」怪兽或「轨道 7」
function c71880877.filter(c,e,tp)
	return (c:IsSetCard(0x85) or c:IsCode(71071546)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 召唤成功时特殊召唤效果的靶向/发动条件检测函数
function c71880877.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的「超级防卫机器人」怪兽或「轨道 7」
		and Duel.IsExistingMatchingCard(c71880877.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 召唤成功时特殊召唤效果的执行函数
function c71880877.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的「超级防卫机器人」怪兽或「轨道 7」
	local g=Duel.SelectMatchingCard(tp,c71880877.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己墓地中可以作为发动代价除外的机械族怪兽，且除外该卡后墓地仍有可回收的目标
function c71880877.rmfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查除外该卡后，墓地中是否还存在其他可以加入手卡的目标怪兽（避免除外唯一的目标导致无法选择）
		and Duel.IsExistingTarget(c71880877.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
-- 过滤墓地中可以加入手卡的「超级防卫机器人」怪兽或「轨道 7」
function c71880877.thfilter(c)
	return (c:IsSetCard(0x85) or c:IsCode(71071546)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 回收效果的发动代价处理函数
function c71880877.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在可作为代价除外的机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71880877.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从墓地选择1只机械族怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c71880877.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 回收效果的靶向/发动条件检测与目标选择函数
function c71880877.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c71880877.thfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择墓地中1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c71880877.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理的操作信息，表示该效果包含将选择的卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行函数
function c71880877.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为连锁对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
