--閃刀起動－リンケージ
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。自己场上1张其他卡送去墓地，从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤。自己的场上·墓地有光属性和暗属性的「闪刀姬」怪兽各存在的场合，这个效果特殊召唤的怪兽的攻击力上升1000。这张卡的发动后，直到回合结束时自己不是「闪刀姬」怪兽不能从额外卡组特殊召唤。
function c9726840.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。自己场上1张其他卡送去墓地，从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤。自己的场上·墓地有光属性和暗属性的「闪刀姬」怪兽各存在的场合，这个效果特殊召唤的怪兽的攻击力上升1000。这张卡的发动后，直到回合结束时自己不是「闪刀姬」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c9726840.condition)
	e1:SetTarget(c9726840.target)
	e1:SetOperation(c9726840.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否在主要怪兽区域
function c9726840.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件：检查自己的主要怪兽区域是否存在怪兽
function c9726840.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区域没有怪兽存在
	return not Duel.IsExistingMatchingCard(c9726840.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：筛选自己场上可以送去墓地且能满足后续特殊召唤条件的卡
function c9726840.tgfilter1(c,e,tp)
	-- 卡片可以送去墓地，且额外卡组存在可以特殊召唤的「闪刀姬」怪兽
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(c9726840.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数：筛选可以特殊召唤的「闪刀姬」怪兽，并确保额外怪兽区域有可用位置
function c9726840.spfilter1(c,e,tp,mc)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查将送去墓地的卡送墓后，额外怪兽区域是否有可用的特殊召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,mc,c,0x60)>0
end
-- 效果发动时的目标选择与操作信息设置
function c9726840.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否存在可以送去墓地且能满足后续特殊召唤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9726840.tgfilter1,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息：包含将自己场上1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	-- 设置操作信息：包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数：在效果处理时筛选可以送去墓地且能成功特殊召唤「闪刀姬」怪兽的卡
function c9726840.tgfilter2(c,e,tp)
	-- 卡片可以送去墓地，且额外卡组存在符合特殊召唤位置要求的「闪刀姬」怪兽
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(c9726840.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数：在效果处理时检查额外卡组的「闪刀姬」怪兽是否能特殊召唤到额外怪兽区域
function c9726840.exfilter(c,e,tp,mc)
	-- 卡片是「闪刀姬」怪兽，且在送去墓地的卡离场后，额外怪兽区域有可用的特殊召唤空间
	return c:IsSetCard(0x1115) and Duel.GetLocationCountFromEx(tp,tp,mc,c,0x60)>0
end
-- 过滤函数：筛选可以特殊召唤到额外怪兽区域的「闪刀姬」怪兽
function c9726840.spfilter2(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,0x60)
end
-- 过滤函数：筛选可以送去墓地且能腾出额外怪兽区域空间的卡（用于处理无法特殊召唤时的异常情况）
function c9726840.tgfilter3(c,tp)
	-- 卡片可以送去墓地，且该卡离场后额外怪兽区域有可用空间
	return c:IsAbleToGrave() and Duel.GetLocationCountFromEx(tp,tp,c,nil,0x60)>0
end
-- 过滤函数：筛选可以送去墓地的卡（用于最坏情况下的处理）
function c9726840.tgfilter4(c)
	return c:IsAbleToGrave()
end
-- 效果处理：将自己场上1张卡送去墓地，从额外卡组把1只「闪刀姬」怪兽在额外怪兽区域特殊召唤，并根据场上·墓地的属性情况决定是否提升攻击力，最后适用额外卡组特殊召唤限制
function c9726840.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有满足“送去墓地后能从额外卡组特殊召唤「闪刀姬」怪兽”条件的卡片组
	local tg2=Duel.GetMatchingGroup(c9726840.tgfilter2,tp,LOCATION_ONFIELD,0,c,e,tp)
	-- 若没有满足正常特殊召唤条件的卡，则获取能送去墓地且能腾出额外怪兽区域空间的卡片组
	local tg3=(#tg2==0) and Duel.GetMatchingGroup(c9726840.tgfilter3,tp,LOCATION_ONFIELD,0,c,tp) or nil
	-- 若上述卡片组都为空，则获取场上仅能送去墓地的卡片组
	local tg4=(tg3 and #tg3==0) and Duel.GetMatchingGroup(c9726840.tgfilter4,tp,LOCATION_ONFIELD,0,c) or nil
	if #tg2>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tc=tg2:Select(tp,1,1,c):GetFirst()
		-- 将选择的卡送去墓地，并检查是否成功送去墓地
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从额外卡组选择1只可以特殊召唤到额外怪兽区域的「闪刀姬」怪兽
			local sc=Duel.SelectMatchingCard(tp,c9726840.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
			if sc then
				-- 将选择的「闪刀姬」怪兽在额外怪兽区域表侧表示特殊召唤
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP,0x60)
				-- 获取自己场上表侧表示及墓地的所有「闪刀姬」怪兽
				local fg=Duel.GetMatchingGroup(c9726840.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
				-- 检查这些「闪刀姬」怪兽中是否同时存在光属性和暗属性
				if fg:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) then
					-- 这个效果特殊召唤的怪兽的攻击力上升1000。
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(1000)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
				end
			end
		end
	elseif tg3 and #tg3>0 then
		-- 提示玩家选择要送去墓地的卡（在无法特殊召唤时的处理）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tc=tg3:Select(tp,1,1,c):GetFirst()
		-- 将选择的卡送去墓地（在无法特殊召唤时的处理）
		Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif tg4 and #tg4>0 then
		-- 提示玩家选择要送去墓地的卡（在最坏情况下的处理）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tc=tg4:Select(tp,1,1,c):GetFirst()
		-- 将选择的卡送去墓地（在最坏情况下的处理）
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是「闪刀姬」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c9726840.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，适用直到回合结束时自己不是「闪刀姬」怪兽不能从额外卡组特殊召唤的限制
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数：筛选自己场上表侧表示或墓地的「闪刀姬」怪兽
function c9726840.atkfilter(c)
	return c:IsSetCard(0x1115) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 特殊召唤限制函数：限制不能从额外卡组特殊召唤「闪刀姬」以外的怪兽
function c9726840.splimit(e,c)
	return not c:IsSetCard(0x1115) and c:IsLocation(LOCATION_EXTRA)
end
