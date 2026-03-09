--幻煌龍の螺旋突
-- 效果：
-- 通常怪兽才能装备。「幻煌龙的螺旋突」的②的效果1回合只能使用1次。
-- ①：装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：装备怪兽给与对方战斗伤害时才能发动。从自己的手卡·卡组·墓地选1只「幻煌龙 螺旋」特殊召唤，这张卡给那只怪兽装备。那之后，可以选对方场上1只攻击表示怪兽变成守备表示。
function c48308134.initial_effect(c)
	-- 装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c48308134.target)
	e1:SetOperation(c48308134.operation)
	c:RegisterEffect(e1)
	-- 通常怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c48308134.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽给与对方战斗伤害时才能发动。从自己的手卡·卡组·墓地选1只「幻煌龙 螺旋」特殊召唤，这张卡给那只怪兽装备。那之后，可以选对方场上1只攻击表示怪兽变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48308134,0))  --"「幻煌龙 螺旋」特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,48308134)
	e4:SetCondition(c48308134.spcon)
	e4:SetTarget(c48308134.sptg)
	e4:SetOperation(c48308134.spop)
	c:RegisterEffect(e4)
end
-- 装备对象必须是通常怪兽
function c48308134.eqlimit(e,c)
	return c:IsType(TYPE_NORMAL)
end
-- 过滤条件：场上表侧表示的通常怪兽
function c48308134.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
-- 选择装备目标：场上的表侧表示通常怪兽
function c48308134.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c48308134.filter(chkc) end
	-- 判断是否满足装备条件：场上存在表侧表示的通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c48308134.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上的表侧表示通常怪兽作为装备对象
	Duel.SelectTarget(tp,c48308134.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果作用
function c48308134.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 诱发条件：对方造成战斗伤害且该伤害由装备怪兽造成
function c48308134.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 过滤条件：「幻煌龙 螺旋」怪兽
function c48308134.spfilter(c,e,tp)
	return c:IsCode(56649609) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤准备：判断是否可以特殊召唤「幻煌龙 螺旋」
function c48308134.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡·卡组·墓地是否存在「幻煌龙 螺旋」
		and Duel.IsExistingMatchingCard(c48308134.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤条件：攻击表示且可以改变表示形式的怪兽
function c48308134.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果作用
function c48308134.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否有足够的魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只「幻煌龙 螺旋」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48308134.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 尝试特殊召唤选中的怪兽
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 将装备卡装备给特殊召唤的怪兽
			Duel.Equip(tp,c,tc)
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
			-- 获取对方场上的攻击表示怪兽
			local g=Duel.GetMatchingGroup(c48308134.posfilter,tp,0,LOCATION_MZONE,nil)
			-- 询问是否选择对方怪兽变为守备表示
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(48308134,1)) then  --"是否选对方怪兽变成守备表示？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				local sg=g:Select(tp,1,1,nil)
				-- 将选中的对方怪兽变为守备表示
				Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
			end
		end
	end
end
