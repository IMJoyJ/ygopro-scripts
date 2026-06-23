--Chevreuil, Hunting Scout of the Deep Forest
-- 效果：
-- 5星以上的战士族·地属性怪兽+战士族·地属性怪兽
-- 这张卡在主要阶段期间不受对方发动的效果影响。
-- 可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击。
-- 自己场上的其他战士族·地属性怪兽战斗破坏对方怪兽时：可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤。「深林狩哨 獐鹿」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤条件、苏生限制和多个永续效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用满足matfilter1和matfilter2条件的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	c:EnableReviveLimit()
	-- 这张卡在主要阶段期间不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.macon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(s.atklimit)
	c:RegisterEffect(e3)
	-- 自己场上的其他战士族·地属性怪兽战斗破坏对方怪兽时：可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 融合素材1的过滤条件：地属性、战士族、5星以上
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5)
end
-- 融合素材2的过滤条件：地属性、战士族
function s.matfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 免疫效果过滤函数：对方发动的效果且在主要阶段时生效
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		-- 且在主要阶段时生效
		and Duel.IsMainPhase()
end
-- 必须攻击条件函数：己方场上存在表侧表示怪兽
function s.macon(e)
	-- 检查己方场上是否存在至少1只表侧表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 攻击限制函数：判断目标怪兽是否为己方场上攻击力最高的怪兽
function s.atklimit(e,c)
	-- 获取己方场上所有表侧表示怪兽中攻击力最高的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsContains(c)
end
-- 战斗破坏的怪兽来源过滤函数：判断是否为己方怪兽战斗破坏对方怪兽
function s.egfilter(c,tp,sc)
	if not c:IsPreviousControler(1-tp) then return false end
	local bc=c:GetReasonCard()
	if not bc or bc==sc then return false end
	if bc:IsRelateToBattle() then
		return bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and bc:IsControler(tp)
			and bc:IsType(TYPE_MONSTER) and bc:IsRace(RACE_WARRIOR) and bc:IsAttribute(ATTRIBUTE_EARTH)
	else
		return bc:GetPreviousPosition()&POS_FACEUP>0 and bc:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and bc:IsPreviousControler(tp)
			and bc:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER and c:GetPreviousRaceOnField()&RACE_WARRIOR==RACE_WARRIOR
			and bc:GetPreviousAttributeOnField()&ATTRIBUTE_EARTH==ATTRIBUTE_EARTH
	end
end
-- 特殊召唤发动条件函数：存在满足egfilter条件的被战斗破坏的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp,e:GetHandler())
end
-- 特殊召唤的卡过滤函数：墓地或除外状态的战士族·地属性怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的发动时点处理函数：检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地或除外区是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只怪兽，目标为己方墓地或除外区的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特殊召唤效果处理函数：选择并特殊召唤满足条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
