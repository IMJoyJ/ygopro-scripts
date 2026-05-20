--銀河剣聖
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只「光子」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。这张卡的等级变成和给人观看的「光子」怪兽的等级相同。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只「银河」怪兽为对象才能发动。这张卡的攻击力·守备力变成和那只怪兽的各自数值相同。
function c55168550.initial_effect(c)
	-- ①：把手卡1只「光子」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。这张卡的等级变成和给人观看的「光子」怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55168550,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55168550)
	e1:SetCost(c55168550.spcost)
	e1:SetTarget(c55168550.sptg)
	e1:SetOperation(c55168550.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己墓地1只「银河」怪兽为对象才能发动。这张卡的攻击力·守备力变成和那只怪兽的各自数值相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55168550,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,55168551)
	e2:SetTarget(c55168550.atktg)
	e2:SetOperation(c55168550.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤手卡中未公开的「光子」怪兽
function c55168550.cfilter(c)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- ①号效果的发动代价（Cost）：展示手卡中1只「光子」怪兽，并记录其等级
function c55168550.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可展示的「光子」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55168550.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认（展示）的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1只满足条件的「光子」怪兽
	local g=Duel.SelectMatchingCard(tp,c55168550.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示所选的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- ①号效果的发动准备（Target）：检查怪兽区域空位以及自身是否能特殊召唤
function c55168550.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理（Operation）：将自身特殊召唤，并将其等级变更为展示怪兽的等级
function c55168550.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lv=e:GetLabel()
	-- 尝试将自身以表侧表示特殊召唤，并判断当前等级是否与展示怪兽的等级不同
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and c:GetLevel()~=lv then
		-- 这张卡的等级变成和给人观看的「光子」怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 过滤自己墓地中具有守备力数值的「银河」怪兽
function c55168550.filter(c)
	return c:IsSetCard(0x7b) and c:IsType(TYPE_MONSTER) and c:IsDefenseAbove(0)
end
-- ②号效果的发动准备（Target）：选择自己墓地1只「银河」怪兽作为对象
function c55168550.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55168550.filter(chkc) end
	-- 检查自己墓地是否存在可作为对象的「银河」怪兽
	if chk==0 then return Duel.IsExistingTarget(c55168550.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只「银河」怪兽作为效果对象
	Duel.SelectTarget(tp,c55168550.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- ②号效果的处理（Operation）：将自身的攻击力·守备力变成与作为对象的怪兽相同
function c55168550.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	if atk>0 then
		-- 这张卡的攻击力·守备力变成和那只怪兽的各自数值相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	if def>0 then
		-- 这张卡的攻击力·守备力变成和那只怪兽的各自数值相同。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(def)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
