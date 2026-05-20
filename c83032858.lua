--エレメントセイバー・アイナ
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以自己墓地1只「元素灵剑士·辟地」以外的「元素灵剑士」怪兽或者「灵神」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c83032858.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以自己墓地1只「元素灵剑士·辟地」以外的「元素灵剑士」怪兽或者「灵神」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83032858,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c83032858.spcost)
	e1:SetTarget(c83032858.sptg)
	e1:SetOperation(c83032858.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83032858,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c83032858.atttg)
	e2:SetOperation(c83032858.attop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以送去墓地的「元素灵剑士」怪兽
function c83032858.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：从手卡将1只「元素灵剑士」怪兽送去墓地（若「灵神之殿」在场则可从卡组送去）
function c83032858.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到「灵神之殿」等卡片效果的影响（允许从卡组将「元素灵剑士」送去墓地代替手卡代价）
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 在发动阶段检查是否存在可作为代价送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83032858.costfilter,tp,loc,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足条件的怪兽卡
	local tc=Duel.SelectMatchingCard(tp,c83032858.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 展示「灵神之殿」的卡片发动动画，提示使用了其代替代价的效果
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 过滤条件：自己墓地中「元素灵剑士·辟地」以外的「元素灵剑士」怪兽或「灵神」怪兽，且可以特殊召唤
function c83032858.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(83032858) and c:IsSetCard(0x400d,0x113) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的发动准备：检查怪兽区域空位并选择墓地中的目标怪兽
function c83032858.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83032858.spfilter(chkc,e,tp) end
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在满足特殊召唤条件的目标怪兽
		and Duel.IsExistingTarget(c83032858.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83032858.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：特殊召唤该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将选择的对象怪兽无视召唤条件特殊召唤
function c83032858.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 效果②的发动准备：让玩家宣言一个属性，并设置涉及墓地的操作信息
function c83032858.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从除自身当前属性以外的所有属性中宣言1个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置当前连锁的操作信息：此效果涉及墓地卡片的状态变化
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：使墓地的这张卡直到回合结束时变成宣言的属性
function c83032858.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
