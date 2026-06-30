--メタル化・強化反射装甲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽从自己的手卡·卡组·墓地特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽攻击力·守备力上升400，不会被魔法·怪兽的效果破坏，对方不能把装备怪兽作为魔法·怪兽的效果的对象。
local s,id,o=GetID()
-- 注册卡片的效果
function s.initial_effect(c)
	-- 在卡片上记载「金属化·强化反射装甲」的卡名
	aux.AddCodeList(c,89812483)
	-- ①：把自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽从自己的手卡·卡组·墓地特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
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
-- 效果发动时代价的处理（设置发动标签）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤自己场上符合解放条件且能使卡组/手卡/墓地特定怪兽特殊召唤的怪兽
function s.filter1(c,e,tp)
	-- 检查怪兽是否表侧表示且解放后是否能让额外/卡组的怪兽特殊召唤的空位大于0
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡、卡组或墓地是否存在满足特殊召唤条件的有「金属化·强化反射装甲」卡名记述的怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,1,c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 过滤手卡、卡组、墓地中记述了「金属化·强化反射装甲」且不能通常召唤的怪兽
function s.filter2(c,e,tp,ft,lv,race,att)
	-- 判断该卡是否是不能通常召唤、效果文本记述了「金属化·强化反射装甲」的怪兽
	if not (not c:IsSummonableCard() and aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER)) then return false end
	local proc=e:GetHandler():IsCode(id) and c.Metallization_material and c.Metallization_material(ft,lv,race,att)
	return c:IsCanBeSpecialSummoned(e,0,tp,proc,proc,POS_FACEUP)
end
-- 卡片发动时的可行性判断与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 如果不检查解放代价，判断手卡、卡组或墓地是否存在满足特殊召唤条件的怪兽
		if e:GetLabel()~=1 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,0) end
		-- 如果检查解放代价，判断自己场上是否存在符合解放条件的怪兽
		return e:IsCostChecked() and Duel.CheckReleaseGroup(tp,s.filter1,1,nil,e,tp)
	end
	if e:GetLabel()==1 then
		-- 选择自己场上1只表侧表示的怪兽进行解放
		local rg=Duel.SelectReleaseGroup(tp,s.filter1,1,1,nil,e,tp)
		local ec=rg:GetFirst()
		e:SetLabel(1,ec:GetLevel(),ec:GetRace(),ec:GetAttribute())
		-- 将被选中的怪兽解放作为发动的代价
		Duel.Release(ec,REASON_COST)
	else
		e:SetLabel(0)
	end
	-- 设置特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 卡片发动效果处理：特殊召唤符合条件的怪兽，并可将这张卡作为装备卡给其装备
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己场上的怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ft,lv,race,att=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡、卡组或墓地中1只满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel()):GetFirst()
	-- 若成功特殊召唤所选怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
		local proc=c:IsCode(id) and tc.Metallization_material and tc.Metallization_material(ft,lv,race,att)
		if proc then tc:CompleteProcedure() end
		-- 若这张卡仍在场上，询问玩家是否将其作为装备卡给特殊召唤的怪兽装备
		if ft==1 and c:IsOnField() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
			-- 中断当前效果以使装备处理与特殊召唤不同时处理
			Duel.BreakEffect()
			c:CancelToGrave(true)
			-- 将这张卡作为装备卡给特殊召唤的怪兽装备
			if Duel.Equip(tp,c,tc) then
				-- 装备怪兽
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				c:RegisterEffect(e1)
				-- 装备怪兽攻击力·守备力上升400
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(400)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				c:RegisterEffect(e3)
				-- 不会被魔法·怪兽的效果破坏
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
-- 过滤合法的装备对象
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断是否是对方玩家的魔法或怪兽效果
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL) and rp==1-e:GetHandlerPlayer()
end
-- 判断效果是否是魔法或怪兽效果
function s.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL)
end
