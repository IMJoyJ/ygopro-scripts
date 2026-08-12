--天魔伏聖剣
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力·守备力上升自己的场上·墓地的装备魔法卡数量×200。
-- ②：这张卡给战士族怪兽装备中的场合才能发动。和装备怪兽是卡名不同并是属性·等级相同的1只战士族怪兽从卡组特殊召唤，这张卡给那只怪兽装备。那之后，这张卡装备过的怪兽破坏。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化效果：添加装备魔法通用装备效果，并注册①的攻击力上升、守备力上升装备效果以及②的起动效果
function s.initial_effect(c)
	-- 为这张卡添加装备魔法的通用装备效果：可以装备给自己或对方场上的表侧表示怪兽
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- ①：装备怪兽的攻击力上升自己的场上·墓地的装备魔法卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的守备力上升自己的场上·墓地的装备魔法卡数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡给战士族怪兽装备中的场合才能发动。
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
-- 效果①的数值函数：计算装备怪兽攻击力·守备力上升的数值
function s.value(e,c)
	-- 统计自己场上·墓地的表侧表示装备魔法卡数量，乘以200作为上升数值
	return Duel.GetMatchingGroupCount(aux.AND(Card.IsAllTypes,Card.IsFaceupEx),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,TYPE_EQUIP+TYPE_SPELL)*200
end
-- 特殊召唤对象的过滤函数：与装备怪兽卡名不同、属性·等级相同的战士族且可以特殊召唤的怪兽
function s.spfilter(c,e,tp,ec)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(ec:GetLevel())
		and c:IsAttribute(ec:GetAttribute()) and not c:IsCode(ec:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标函数：取得装备怪兽，并检查发动条件是否满足
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 效果处理可行性检查：自己主要怪兽区需有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and ec:IsRace(RACE_WARRIOR) and ec:IsFaceup()
		-- 检查卡组是否存在满足条件的特殊召唤对象（且装备怪兽是表侧表示的战士族）
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ec) end
	-- 设置操作信息：本效果将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本效果将破坏装备怪兽（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 效果②的处理函数：注册特殊召唤限制，选卡组怪兽特殊召唤并装备这张卡，那之后破坏原装备怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。和装备怪兽是卡名不同并是属性·等级相同的1只战士族怪兽从卡组特殊召唤，这张卡给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「自己不能特殊召唤战士族以外的怪兽」的限制注册为玩家的全局效果
	Duel.RegisterEffect(e1,tp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 若自己主要怪兽区没有空位则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示：「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec)
	local tc=g:GetFirst()
	-- 关闭卡片的自爆检查（避免装备转移过程中装备怪兽因失去装备卡而被规则破坏）
	Duel.DisableSelfDestroyCheck()
	-- 将选中的怪兽表侧表示特殊召唤，成功后把这张卡装备给那只怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 这张卡给那只怪兽装备（设定装备限制：只能装备给那只怪兽）
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(s.eqlimit)
		c:RegisterEffect(e2)
		if ec then
			-- 中断当前效果处理，使之后的破坏视为不同时处理（错时点）
			Duel.BreakEffect()
			-- 以效果破坏这张卡装备过的原装备怪兽
			Duel.Destroy(ec,REASON_EFFECT)
		end
	end
	-- 恢复卡片的自爆检查
	Duel.DisableSelfDestroyCheck(false)
end
-- 装备限制函数：这张卡只能装备给该效果的所有者（即被特殊召唤的那只怪兽）
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 特殊召唤限制的过滤函数：对战士族以外的怪兽生效（即不能特殊召唤非战士族怪兽）
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
