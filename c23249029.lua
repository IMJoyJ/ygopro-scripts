--Cursed Copycat Noble Arms
-- 效果：
-- 装备怪兽的攻击力·守备力上升自己场上或墓地的装备魔法卡的数量×200。
-- 这张卡给战士族怪兽装备中的场合：可以把这个效果发动；直到回合结束时，自己不是战士族怪兽不能特殊召唤，从卡组把属性·等级和装备怪兽相同而卡名不同的1只战士族怪兽特殊召唤，这张卡给那只怪兽装备，那之后，把这张卡装备过的怪兽破坏。「咒怨仿品·圣剑」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 注册装备魔法卡的标准效果，包括装备限制和发动条件
function s.initial_effect(c)
	-- 为装备魔法卡注册标准的装备效果，允许装备给己方或对方场上满足条件的怪兽
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- 装备怪兽的攻击力上升自己场上或墓地的装备魔法卡的数量×200
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	-- 装备怪兽的守备力上升自己场上或墓地的装备魔法卡的数量×200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- 这张卡给战士族怪兽装备中的场合：可以把这个效果发动；直到回合结束时，自己不是战士族怪兽不能特殊召唤，从卡组把属性·等级和装备怪兽相同而卡名不同的1只战士族怪兽特殊召唤，这张卡给那只怪兽装备，那之后，把这张卡装备过的怪兽破坏。「咒怨仿品·圣剑」的这个效果1回合只能使用1次
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
-- 计算装备魔法卡数量并乘以200作为攻击力和守备力的加成值
function s.value(e,c)
	-- 检索满足条件的装备魔法卡数量（包括场上和墓地）
	return Duel.GetMatchingGroupCount(aux.AND(Card.IsAllTypes,Card.IsFaceupEx),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_EQUIP+TYPE_SPELL)*200
end
-- 筛选可以特殊召唤的战士族怪兽，要求属性、等级与装备怪兽相同且卡名不同
function s.spfilter(c,e,tp,ec)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(ec:GetLevel())
		and c:IsAttribute(ec:GetAttribute()) and not c:IsCode(ec:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件，包括装备怪兽为战士族且处于表侧表示，以及卡组中存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsRace(RACE_WARRIOR) and ec:IsFaceup()
		-- 判断卡组中是否存在满足条件的战士族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ec) end
	-- 设置操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将破坏装备怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 处理特殊召唤效果的执行逻辑，包括设置不能特殊召唤的限制、选择并特殊召唤怪兽、装备该卡并破坏原装备怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置效果，使自己不能特殊召唤非战士族怪兽直到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家，使其生效
	Duel.RegisterEffect(e1,tp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的战士族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec)
	local tc=g:GetFirst()
	-- 关闭卡片的自爆检查
	Duel.DisableSelfDestroyCheck()
	-- 执行特殊召唤并装备该卡，若成功则设置装备限制效果
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 为被特殊召唤的怪兽设置装备限制，确保只能被该装备卡装备
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(s.eqlimit)
		c:RegisterEffect(e2)
		if ec then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 破坏装备怪兽
			Duel.Destroy(ec,REASON_EFFECT)
		end
	end
	-- 重新启用卡片的自爆检查
	Duel.DisableSelfDestroyCheck(false)
end
-- 定义装备限制效果的判断函数，确保只能装备给该卡本身
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 定义不能特殊召唤的限制函数，禁止非战士族怪兽特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
