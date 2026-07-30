--天魔伏聖剣
-- 效果：
-- 装备怪兽的攻击力·守备力上升自己场上或墓地的装备魔法卡的数量×200。
-- 这张卡给战士族怪兽装备中的场合：可以把这个效果发动；直到回合结束时，自己不是战士族怪兽不能特殊召唤，从卡组把属性·等级和装备怪兽相同而卡名不同的1只战士族怪兽特殊召唤，这张卡给那只怪兽装备，那之后，把这张卡装备过的怪兽破坏。「咒怨仿品·圣剑」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 为装备魔法卡添加通用的装备效果及装备限制效果，包括攻击力和守备力上升效果，以及特殊召唤效果
function s.initial_effect(c)
	-- 注册装备魔法卡的基本装备逻辑，允许装备给己方和对方怪兽，且装备怪兽必须表侧表示
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- 装备怪兽的攻击力上升效果，数值为己方场上或墓地的装备魔法卡数量×200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	-- 装备怪兽的守备力上升效果，数值为己方场上或墓地的装备魔法卡数量×200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- 发动时可以特殊召唤符合条件的战士族怪兽并装备自身，且破坏装备怪兽，每回合只能发动一次
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 计算装备怪兽攻击力和守备力上升的数值，即己方场上或墓地的装备魔法卡数量乘以200
function s.value(e,c)
	-- 获取己方场上或墓地的装备魔法卡数量，并乘以200作为攻击力和守备力的提升值
	return Duel.GetMatchingGroupCount(aux.AND(Card.IsAllTypes,Card.IsFaceupEx),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_EQUIP+TYPE_SPELL)*200
end
-- 筛选可以从卡组特殊召唤的战士族怪兽，要求属性、等级与装备怪兽相同但卡名不同
function s.spfilter(c,e,tp,ec)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(ec:GetLevel())
		and c:IsAttribute(ec:GetAttribute()) and not c:IsCode(ec:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动特殊召唤效果，检查是否有足够的召唤位置和符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查是否有足够的召唤位置来特殊召唤怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsRace(RACE_WARRIOR) and ec:IsFaceup()
		-- 检查卡组中是否存在符合条件的战士族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ec) end
	-- 设置操作信息，表示将从卡组特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将破坏装备怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 处理特殊召唤效果，包括限制召唤、选择怪兽、装备并破坏原怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建并注册不能特殊召唤的限制效果，同时选择要特殊召唤的怪兽并进行装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册给玩家，使其在回合结束前无法特殊召唤非战士族怪兽
	Duel.RegisterEffect(e1,tp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查是否有足够的召唤位置，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的战士族怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec)
	local tc=g:GetFirst()
	-- 关闭卡片自爆检查，防止在处理过程中被自动破坏
	Duel.DisableSelfDestroyCheck()
	-- 执行特殊召唤和装备操作，若成功则设置装备限制并破坏原装备怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 为新特殊召唤的怪兽添加装备限制效果，确保只能被此装备卡装备
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(s.eqlimit)
		c:RegisterEffect(e2)
		if ec then
			-- 中断当前效果处理，使后续效果视为错时点处理
			Duel.BreakEffect()
			-- 将装备怪兽破坏
			Duel.Destroy(ec,REASON_EFFECT)
		end
	end
	-- 重新启用卡片自爆检查
	Duel.DisableSelfDestroyCheck(false)
end
-- 设置装备限制函数，确保只有装备卡本身能装备给目标怪兽
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 设置召唤限制函数，禁止非战士族怪兽特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
