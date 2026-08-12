--幻煌龍の螺旋絞
-- 效果：
-- 通常怪兽才能装备。「幻煌龙的螺旋绞」的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升500。
-- ②：装备怪兽战斗破坏对方怪兽时才能发动。从自己的手卡·卡组·墓地选1只「幻煌龙 螺旋」特殊召唤，这张卡给那只怪兽装备。那之后，给与对方1000伤害。
function c75702749.initial_effect(c)
	-- 通常怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c75702749.target)
	e1:SetOperation(c75702749.operation)
	c:RegisterEffect(e1)
	-- 通常怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c75702749.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- ②：装备怪兽战斗破坏对方怪兽时才能发动。从自己的手卡·卡组·墓地选1只「幻煌龙 螺旋」特殊召唤，这张卡给那只怪兽装备。那之后，给与对方1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75702749,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,75702749)
	e4:SetCondition(c75702749.spcon)
	e4:SetTarget(c75702749.sptg)
	e4:SetOperation(c75702749.spop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备于通常怪兽
function c75702749.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL)
end
-- 过滤条件：场上表侧表示的通常怪兽
function c75702749.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 装备魔法卡发动时的效果处理（选择装备对象）
function c75702749.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c75702749.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c75702749.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的通常怪兽作为装备对象
	Duel.SelectTarget(tp,c75702749.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果包含装备操作，对象是这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理（将这张卡装备给目标怪兽）
function c75702749.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 发动条件：装备怪兽战斗破坏怪兽时
function c75702749.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- 过滤条件：手卡·卡组·墓地中可以特殊召唤的「幻煌龙 螺旋」
function c75702749.spfilter(c,e,tp)
	return c:IsCode(56649609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与合法性检查
function c75702749.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡、卡组、墓地是否存在可以特殊召唤的「幻煌龙 螺旋」
		and Duel.IsExistingMatchingCard(c75702749.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：包含从手卡·卡组·墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息：包含将这张卡重新装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：包含给与对方1000点伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果②的效果处理（特殊召唤、重新装备并给予伤害）
function c75702749.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只「幻煌龙 螺旋」（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75702749.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 尝试将选择的怪兽以表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 将这张卡装备给特殊召唤的怪兽
			Duel.Equip(tp,c,tc)
			-- 完成特殊召唤的流程
			Duel.SpecialSummonComplete()
			-- 中断效果，使后续的伤害处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 给与对方1000点效果伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
