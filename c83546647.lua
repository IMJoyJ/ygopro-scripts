--無抵抗の真相
-- 效果：
-- 对方怪兽的直接攻击让自己受到战斗伤害时，把手卡1只1星怪兽给对方观看发动。给对方观看的1只怪兽和自己卡组存在的1只同名怪兽在自己场上特殊召唤。
function c83546647.initial_effect(c)
	-- 对方怪兽的直接攻击让自己受到战斗伤害时，把手卡1只1星怪兽给对方观看发动。给对方观看的1只怪兽和自己卡组存在的1只同名怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c83546647.condition)
	e1:SetCost(c83546647.cost)
	e1:SetTarget(c83546647.target)
	e1:SetOperation(c83546647.activate)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查是否满足对方怪兽直接攻击造成战斗伤害的时点
function c83546647.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断伤害来源是否为对方控制的怪兽、受到伤害的玩家是否为自己、且攻击对象为空（即直接攻击）
	return eg:GetFirst():IsControler(1-tp) and ep==tp and Duel.GetAttackTarget()==nil
end
-- 定义手卡怪兽过滤条件：1星、未公开、可以特殊召唤，且卡组中存在同名怪兽
function c83546647.spfilter(c,e,tp)
	return c:IsLevel(1) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在至少1张可以特殊召唤的同名怪兽
		and Duel.IsExistingMatchingCard(c83546647.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 定义卡组怪兽过滤条件：与指定卡同名且可以特殊召唤
function c83546647.spfilter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义Cost函数：重置Label标记，用于在Target中区分发动检测与实际发动
function c83546647.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	return true
end
-- 定义Target函数：进行发动检测，并让玩家选择手卡怪兽给对方确认，设置特殊召唤的操作信息
function c83546647.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=0 then return false end
		e:SetLabel(1)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查自己的怪兽区域是否有2个以上的空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			-- 检查手卡中是否存在满足条件的1星怪兽
			and Duel.IsExistingMatchingCard(c83546647.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置选择卡片时的提示信息为“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的1星怪兽
	local g=Duel.SelectMatchingCard(tp,c83546647.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的手卡怪兽给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 将给对方确认的怪兽设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置特殊召唤的操作信息，涉及手卡和卡组共2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理函数：将给对方观看的手卡怪兽和卡组中的同名怪兽在自己场上特殊召唤
function c83546647.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己的怪兽区域空位不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取之前给对方观看并设为对象的手卡怪兽
	local tc1=Duel.GetFirstTarget()
	if not tc1:IsRelateToEffect(e) or not tc1:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 从卡组中寻找1只与该手卡怪兽同名的怪兽
	local tc2=Duel.GetFirstMatchingCard(c83546647.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,tc1:GetCode())
	if tc2 then
		-- 将手卡中给对方观看的怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 将卡组中的同名怪兽以表侧表示特殊召唤（分步处理）
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		-- 完成所有分步特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
