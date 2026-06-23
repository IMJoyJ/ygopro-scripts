--サンダー・ディスチャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「勇者衍生物」存在的场合，以把有「勇者衍生物」的衍生物名记述的装备卡装备的自己场上1只怪兽为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上的怪兽全部破坏。那之后，可以从自己的手卡·墓地选有「勇者衍生物」的衍生物名记述的1张装备魔法卡给自己场上1只可以装备的怪兽装备。
local s,id,o=GetID()
-- 注册卡片效果，设置发动条件、目标和处理函数
function c27623932.initial_effect(c)
	-- 记录该卡效果文本中记载着「勇者衍生物」的卡名
	aux.AddCodeList(c,3285552)
	-- ①：自己场上有「勇者衍生物」存在的场合，以把有「勇者衍生物」的衍生物名记述的装备卡装备的自己场上1只怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,27623932+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c27623932.condition)
	e1:SetTarget(c27623932.target)
	e1:SetOperation(c27623932.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在表侧表示的「勇者衍生物」
function c27623932.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 发动条件：检查自己场上是否存在表侧表示的「勇者衍生物」
function c27623932.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「勇者衍生物」
	return Duel.IsExistingMatchingCard(c27623932.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：检查自己场上是否存在装备有「勇者衍生物」装备卡的怪兽，并且对方场上有攻击力低于该怪兽的怪兽
function c27623932.tgfilter(c,tp)
	return c:IsFaceup() and c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(c27623932.cfilter2,1,nil)
		-- 检查对方场上有攻击力低于该怪兽的怪兽
		and Duel.IsExistingMatchingCard(c27623932.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤函数：检查装备卡是否记载着「勇者衍生物」
function c27623932.cfilter2(c)
	-- 检查装备卡是否记载着「勇者衍生物」
	return c:IsFaceup() and aux.IsCodeListed(c,3285552)
end
-- 过滤函数：检查对方场上的怪兽攻击力是否低于指定值
function c27623932.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 设置效果目标，选择符合条件的自己场上的怪兽
function c27623932.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27623932.tgfilter(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c27623932.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的自己场上的怪兽作为目标
	local g=Duel.SelectTarget(tp,c27623932.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取对方场上有攻击力低于目标怪兽攻击力的怪兽组
	local dg=Duel.GetMatchingGroup(c27623932.desfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 设置效果处理信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 过滤函数：检查场上怪兽是否可以装备指定的装备卡
function c27623932.CanEquipFilter(c,eqc)
	return c:IsFaceup() and eqc:CheckEquipTarget(c)
end
-- 过滤函数：检查手牌或墓地中的装备魔法卡是否记载着「勇者衍生物」且可以装备
function c27623932.eqfilter(c,tp)
	-- 检查装备魔法卡是否记载着「勇者衍生物」且类型为装备魔法
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查是否存在可以装备该装备卡的怪兽
		and Duel.IsExistingMatchingCard(c27623932.CanEquipFilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 效果处理函数：破坏对方怪兽并可装备装备魔法卡
function c27623932.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取对方场上有攻击力低于目标怪兽攻击力的怪兽组
		local dg=Duel.GetMatchingGroup(c27623932.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		-- 破坏对方怪兽，检查场上是否有装备区域
		if Duel.Destroy(dg,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 检查手牌或墓地是否存在可装备的装备魔法卡
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
			-- 询问玩家是否选择装备魔法卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选装备魔法卡装备？"
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 选择符合条件的装备魔法卡
			local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp)
			local eqc=eqg:GetFirst()
			-- 提示玩家选择表侧表示的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 选择可以装备该装备卡的怪兽
			local mg=Duel.SelectMatchingCard(tp,s.CanEquipFilter,tp,LOCATION_MZONE,0,1,1,nil,eqc)
			-- 将装备魔法卡装备给指定怪兽
			Duel.Equip(tp,eqc,mg:GetFirst())
		end
	end
end
