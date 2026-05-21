--メタル化・強化反射装甲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽从自己的手卡·卡组·墓地特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽攻击力·守备力上升400，不会被魔法·怪兽的效果破坏，对方不能把装备怪兽作为魔法·怪兽的效果的对象。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 建立与「金属化·强化反射装甲」（卡号89812483）的关联，用于卡片效果文本检索。
	aux.AddCodeList(c,89812483)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽从自己的手卡·卡组·墓地特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）判定与处理函数，设置标签以标记是否进行了代价检查。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤函数1：筛选场上可以解放的表侧表示怪兽，且该怪兽解放后能满足特殊召唤手卡·卡组·墓地特定怪兽的条件。
function s.filter1(c,e,tp)
	-- 检查怪兽是否表侧表示，且解放该怪兽后能空出至少一个怪兽区域。
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己的手卡、卡组、墓地中是否存在至少1张满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,1,c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 过滤函数2：筛选手卡、卡组、墓地中记述了「金属化·强化反射装甲」且不能通常召唤的怪兽，并检查其是否能被特殊召唤。
function s.filter2(c,e,tp,ft,lv,race,att)
	-- 过滤条件：必须是不能通常召唤的怪兽，且卡名记述了「金属化·强化反射装甲」。
	if not (not c:IsSummonableCard() and aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER)) then return false end
	local proc=e:GetHandler():IsCode(id) and c.Metallization_material and c.Metallization_material(ft,lv,race,att)
	return c:IsCanBeSpecialSummoned(e,0,tp,proc,proc,POS_FACEUP)
end
-- 效果发动时的目标选择与代价支付处理函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 如果不是在发动时（例如被其他卡的效果复制发动），则直接检查手卡、卡组、墓地是否存在可特殊召唤的怪兽。
		if e:GetLabel()~=1 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,0) end
		-- 检查是否满足发动代价，即场上是否存在可解放的、满足后续特召条件的怪兽。
		return e:IsCostChecked() and Duel.CheckReleaseGroup(tp,s.filter1,1,nil,e,tp)
	end
	if e:GetLabel()==1 then
		-- 玩家选择场上1只满足条件的表侧表示怪兽作为解放对象。
		local rg=Duel.SelectReleaseGroup(tp,s.filter1,1,1,nil,e,tp)
		local ec=rg:GetFirst()
		e:SetLabel(1,ec:GetLevel(),ec:GetRace(),ec:GetAttribute())
		-- 将选中的怪兽解放作为发动的代价。
		Duel.Release(ec,REASON_COST)
	else
		e:SetLabel(0)
	end
	-- 设置连锁处理信息：从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理（Activate）函数，执行特殊召唤及后续的装备处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位，若无则无法特殊召唤，效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ft,lv,race,att=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡、卡组、墓地选择1只满足条件的怪兽（受王家长眠之谷影响）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel()):GetFirst()
	-- 若成功将选中的怪兽无视召唤条件特殊召唤。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
		local proc=c:IsCode(id) and tc.Metallization_material and tc.Metallization_material(ft,lv,race,att)
		if proc then tc:CompleteProcedure() end
		-- 检查是否满足装备条件（此卡在场上且与效果相关联），并询问玩家是否将其作为装备卡装备给该怪兽。
		if ft==1 and c:IsOnField() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
			-- 中断当前效果处理，使后续的装备处理不与特殊召唤视为同时处理。
			Duel.BreakEffect()
			c:CancelToGrave(true)
			-- 尝试将此卡作为装备卡装备给特殊召唤的怪兽。
			if Duel.Equip(tp,c,tc)~=0 then
				-- 可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				c:RegisterEffect(e1)
				-- ●装备怪兽攻击力·守备力上升400
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(400)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				c:RegisterEffect(e3)
				-- ●不会被魔法·怪兽的效果破坏
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_EQUIP)
				e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
				e4:SetValue(s.efilter)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e4)
				local e5=e4:Clone()
				e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e5:SetValue(s.tgval)
				c:RegisterEffect(e5)
			else
				c:CancelToGrave(false)
			end
		end
	end
end
-- 装备限制函数，规定此卡只能装备给由其效果特殊召唤的怪兽。
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 对方不能把装备怪兽作为魔法·怪兽的效果的对象。
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL) and rp==1-e:GetHandlerPlayer()
end
-- 不会被魔法·怪兽的效果破坏
function s.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL)
end
