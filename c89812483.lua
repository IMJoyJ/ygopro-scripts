--メタル化・強化反射装甲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽从自己的手卡·卡组·墓地特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽攻击力·守备力上升400，不会被魔法·怪兽的效果破坏，对方不能把装备怪兽作为魔法·怪兽的效果的对象。
local s,id,o=GetID()
-- 初始化这张卡的效果：注册「金属化·强化反射装甲」的卡名记载信息，并注册一个可在自由时点发动的陷阱卡发动效果（特殊召唤+装备，1回合1次的发动誓约限制）
function s.initial_effect(c)
	-- 在这张卡上登记卡号89812483，即标记本卡的效果文本上记载着「金属化·强化反射装甲」的卡名，供aux.IsCodeListed检测
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
-- 发动代价函数：给效果打上标签1，标记本次发动经过代价检查（需要解放怪兽）；chk==0时不做实质检查直接返回真，真正的可发动性检查在target中进行
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤函数filter1：筛选可作为代价解放的表侧表示怪兽，要求该怪兽离场后自己场上仍有可用怪兽区，且手卡·卡组·墓地存在与之等级·种族·属性匹配、满足特殊召唤条件的「金属化」怪兽
function s.filter1(c,e,tp)
	-- 判断该卡为表侧表示，并且假设该卡离场后自己场上仍有至少1个可用的怪兽区域
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		-- 并检查自己的卡组·手卡·墓地中是否存在至少1只满足filter2条件的怪兽（以该解放怪兽的等级·种族·属性作为Metallization_material的匹配参数）
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,1,c:GetLevel(),c:GetRace(),c:GetAttribute())
end
-- 过滤函数filter2：筛选可特殊召唤的怪兽——必须是记载了「金属化·强化反射装甲」卡名、不能通常召唤的怪兽，并根据其Metallization_material素材条件判断是否满足召唤手续，最后确认其可以被特殊召唤
function s.filter2(c,e,tp,ft,lv,race,att)
	-- 排除不符合条件的卡：必须是不能通常召唤、效果文本上记载着「金属化·强化反射装甲」卡名的怪兽卡，否则返回假
	if not (not c:IsSummonableCard() and aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER)) then return false end
	local proc=e:GetHandler():IsCode(id) and c.Metallization_material and c.Metallization_material(ft,lv,race,att)
	return c:IsCanBeSpecialSummoned(e,0,tp,proc,proc,POS_FACEUP)
end
-- 发动对象函数：可发动性检查时，若未经代价则只需确认手卡·卡组·墓地存在可特殊召唤的怪兽；经过代价则需确认存在可解放的表侧表示怪兽。实际发动时让玩家选择1只解放、记录其等级·种族·属性，并设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若本次检查未经过代价处理（Label不为1），则只检查自己的卡组·手卡·墓地是否存在至少1只满足filter2条件的可特殊召唤怪兽
		if e:GetLabel()~=1 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,0) end
		-- 确认本次发动了代价检查，并检查自己场上是否存在至少1只满足filter1条件的可解放怪兽
		return e:IsCostChecked() and Duel.CheckReleaseGroup(tp,s.filter1,1,nil,e,tp)
	end
	if e:GetLabel()==1 then
		-- 让玩家从自己场上选择1只满足filter1条件的表侧表示怪兽作为解放对象
		local rg=Duel.SelectReleaseGroup(tp,s.filter1,1,1,nil,e,tp)
		local ec=rg:GetFirst()
		e:SetLabel(1,ec:GetLevel(),ec:GetRace(),ec:GetAttribute())
		-- 将选定的怪兽作为发动代价解放
		Duel.Release(ec,REASON_COST)
	else
		e:SetLabel(0)
	end
	-- 设置操作信息：本次效果处理将从卡组·手卡·墓地特殊召唤1只怪兽，供星尘龙、王家长眠之谷等效果检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：确认自己怪兽区有空位后，让玩家从卡组·手卡·墓地选1只满足条件的「金属化」怪兽特殊召唤（无视召唤条件和苏生限制），若素材条件满足则完成正规召唤手续；之后若这张卡是正常发动（ft==1）且仍在场上，可询问玩家是否把这张卡当作装备卡给那只怪兽装备，装备成功则赋予攻击力·守备力上升400、不会被魔法·怪兽效果破坏、对方不能以其为魔法·怪兽效果对象的装备效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果自己场上没有可用的怪兽区域则中断效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ft,lv,race,att=e:GetLabel()
	-- 向玩家发送选择提示消息「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组·手卡·墓地选择1只满足filter2条件（经王家长眠之谷过滤）的怪兽，并取出该卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel()):GetFirst()
	-- 若选中了卡，则以无视召唤条件、无视苏生限制的方式将其以表侧攻击表示特殊召唤到自己场上，且特殊召唤成功
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
		local proc=c:IsCode(id) and tc.Metallization_material and tc.Metallization_material(ft,lv,race,att)
		if proc then tc:CompleteProcedure() end
		-- 若本次是这张卡自身的发动（ft==1）、这张卡仍在场上且仍与效果关联，则询问玩家是否把这张卡给那只怪兽装备
		if ft==1 and c:IsOnField() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否装备？"
			-- 中断当前效果处理，使之后的装备处理视为与特殊召唤不同时处理（错开时点）
			Duel.BreakEffect()
			c:CancelToGrave(true)
			-- 尝试把这张卡作为装备卡装备给那只特殊召唤的怪兽，装备成功则进入后续效果赋予
			if Duel.Equip(tp,c,tc) then
				-- ●装备怪兽（装备限制：这张卡只能装备给那只被特殊召唤的怪兽）
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				c:RegisterEffect(e1)
				-- ●装备怪兽攻击力上升400
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(400)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_UPDATE_DEFENSE)
				c:RegisterEffect(e3)
				-- ●装备怪兽不会被魔法·怪兽的效果破坏
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
-- 装备限制函数：这张卡只能装备给作为其装备对象登录的那只怪兽（即效果拥有者指定的对象）
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 对象限制判断函数：仅对对方玩家发动的怪兽·魔法卡的效果生效，使装备怪兽不会成为对方魔法·怪兽效果的对象
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL) and rp==1-e:GetHandlerPlayer()
end
-- 破坏耐性过滤函数：仅对怪兽·魔法卡的效果生效，使装备怪兽不会被魔法·怪兽的效果破坏
function s.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL)
end
