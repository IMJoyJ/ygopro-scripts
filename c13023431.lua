--密林の狩猟者シュヴルイユ
-- 效果：
-- 5星以上的战士族·地属性怪兽＋战士族·地属性怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，自己·对方的主要阶段内，不受对方发动的效果影响。
-- ②：其他的自己的战士族·地属性怪兽战斗破坏对方怪兽时才能发动。自己的墓地·除外状态的1只战士族·地属性怪兽特殊召唤。
-- ③：可以攻击的对方怪兽必须向自己场上的攻击力最高的怪兽作出攻击。
local s,id,o=GetID()
-- 初始化效果：设置融合召唤手续与苏生限制，注册①不受对方效果影响的永续效果、②强制对方怪兽攻击的永续效果、③战斗破坏时特殊召唤的诱发选发效果
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：用满足matfilter1（5星以上的战士族·地属性怪兽）与matfilter2（战士族·地属性怪兽）的怪兽各1只作为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	c:EnableReviveLimit()
	-- ①：这张卡只要在怪兽区域存在，自己·对方的主要阶段内，不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- ③：可以攻击的对方怪兽必须向自己场上的攻击力最高的怪兽作出攻击。
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
	-- ②：其他的自己的战士族·地属性怪兽战斗破坏对方怪兽时才能发动。自己的墓地·除外状态的1只战士族·地属性怪兽特殊召唤。这个卡名的②的效果1回合只能使用1次。
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
-- 融合素材过滤条件1：5星以上的战士族·地属性怪兽
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5)
end
-- 融合素材过滤条件2：战士族·地属性怪兽
function s.matfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 效果免疫的适用条件：效果由对方玩家发动（其持有者不是这张卡的控制者），且当前处于主要阶段
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		-- 并且当前处于主要阶段（自己或对方的主要阶段）
		and Duel.IsMainPhase()
end
-- 强制攻击效果的适用条件：自己怪兽区域存在表侧表示的怪兽
function s.macon(e)
	-- 检查自己怪兽区域是否存在至少1只表侧表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 攻击目标限定：对方怪兽攻击时，必须攻击自己场上表侧表示怪兽中攻击力最高的怪兽
function s.atklimit(e,c)
	-- 检索自己怪兽区域全部表侧表示怪兽，并取出其中攻击力最高的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsContains(c)
end
-- 战斗破坏触发过滤：被破坏的是原本由对方控制的怪兽，且战斗破坏它的怪兽（不是这张卡本身）是满足条件的自己的战士族·地属性怪兽（依其当前状态或离场前状态判定）
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
-- ②效果的发动条件：本次被战斗破坏的怪兽中存在满足egfilter条件的卡（即被自己的其他战士族·地属性怪兽战斗破坏的对方怪兽）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp,e:GetHandler())
end
-- 特殊召唤对象过滤：墓地·除外状态的表侧的战士族·地属性怪兽，且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标设定：发动条件检查——自己怪兽区域有空位，且自己的墓地·除外状态存在可以特殊召唤的战士族·地属性怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查时，先确认自己怪兽区域有1个以上的可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己的墓地·除外状态存在至少1只满足特殊召唤条件的战士族·地属性怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将进行1次特殊召唤，对象是持有者为自己的墓地·除外状态的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的处理：确认自己怪兽区域有空位后，让玩家从自己的墓地·除外状态选1只满足条件的战士族·地属性怪兽，以表侧表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己怪兽区域没有可用空位，则效果不再处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的墓地·除外状态选择1只满足条件的战士族·地属性怪兽（附加王家长眠之谷过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
