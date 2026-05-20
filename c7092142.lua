--激流蘇生
-- 效果：
-- 自己场上的水属性怪兽被战斗或者卡的效果破坏送去墓地时才能发动。那个时候被破坏从场上送去自己墓地的怪兽全部特殊召唤，给与对方基本分特殊召唤的怪兽数量×500的数值的伤害。「激流苏生」在1回合只能发动1张。
function c7092142.initial_effect(c)
	-- 自己场上的水属性怪兽被战斗或者卡的效果破坏送去墓地时才能发动。那个时候被破坏从场上送去自己墓地的怪兽全部特殊召唤，给与对方基本分特殊召唤的怪兽数量×500的数值的伤害。「激流苏生」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,7092142+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c7092142.condition)
	e1:SetTarget(c7092142.target)
	e1:SetOperation(c7092142.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：被破坏、原本在怪兽区域、原本由自身控制、原本是表侧表示的水属性怪兽
function c7092142.cfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsAttribute(ATTRIBUTE_WATER) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WATER)~=0
end
-- 发动条件：检测被送去墓地的卡片中是否存在满足过滤条件的水属性怪兽
function c7092142.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7092142.cfilter,1,nil,tp)
end
-- 特殊召唤过滤条件：原本在怪兽区域、当前由自身控制且可以特殊召唤的怪兽
function c7092142.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与检测：验证是否有可特殊召唤的怪兽、检测场地空格及特殊限制，并设置操作信息
function c7092142.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=eg:FilterCount(c7092142.spfilter,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
			-- 检测自身场上的可用怪兽区域空格数是否大于或等于需要特殊召唤的怪兽数量
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
	end
	-- 将触发效果的怪兽组（被破坏送去墓地的怪兽）设为效果处理的对象
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c7092142.spfilter,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含特殊召唤的卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理时的特殊召唤过滤条件：在上述条件基础上，还需满足仍与此效果相关联
function c7092142.spfilter2(c,e,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：将满足条件的怪兽全部特殊召唤，并根据成功特殊召唤的数量给予对方相应的伤害
function c7092142.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local sg=eg:Filter(c7092142.spfilter2,nil,e,tp)
	if ft<sg:GetCount() then return end
	-- 将目标怪兽以表侧表示特殊召唤到自身场上，并返回成功特殊召唤的数量
	local ct=Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	if ct==0 then return end
	-- 中断当前效果处理，使后续的伤害处理与特殊召唤不视为同时进行
	Duel.BreakEffect()
	-- 给予对方玩家相当于成功特殊召唤的怪兽数量乘以500的数值的伤害
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
