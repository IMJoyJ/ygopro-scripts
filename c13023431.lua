--密林の狩猟者シュヴルイユ
-- 效果：
-- 5星以上的战士族·地属性怪兽+战士族·地属性怪兽
-- 这张卡在主要阶段期间不受对方发动的效果影响。
-- 可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击。
-- 自己场上的其他战士族·地属性怪兽战斗破坏对方怪兽时：可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤。「深林狩哨 獐鹿」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化效果处理函数，添加融合召唤手续（需2只战士族·地属性怪兽，其中至少一只5星以上），开启苏生限制，并注册三个主要效果组件
function s.initial_effect(c)
	-- 为c 添加融合召唤手续，使用 s.matfilter1 和 s.matfilter2 定义的素材条件各选1只怪兽进行融合召唤
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	c:EnableReviveLimit()
	-- 对应原文'这张卡在主要阶段期间不受对方发动的效果影响'：创建一个单卡永续效果（EFFECT_TYPE_SINGLE），类型为 EFFEECT_IMMUNE_EFFECT，范围限定为场上正面表示的怪兽区，判断值为对手玩家激活且在主阶段的卡片
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- 对应原文'可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击'的第一部分：创建一个全场触发式效果（EFFECT_TYPE_FIELD）配合 EFFECT_MUST_ATTACK 类型，范围为自身场下怪兽区，条件为场上存在至少1只表侧表示怪兽
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
	-- 对应原文'可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击'的第二部分及第三段效果的复合定义：克隆前一个效果并修改代码为 EFFECT_MUST_ATTACK_MONSTER（若攻击则必须攻击X），值为 s.atklimit 函数；同时创建一个触发式字段效果，类型为 FIELD+TRIGGER_O，触发时机为战斗破坏时，范围为自身场下怪兽区，限制1回合1次，条件/目标/处理分别由 spcon/sptg/sspop 定义
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
-- 对应原文'5星以上的战士族·地属性怪兽'的素材过滤函数：返回满足融合属性地为、种族战士且等级大于等于5星的卡片
function s.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(5)
end
-- 对应原文'+战士族·地属性怪兽'的第二部分素材过滤函数：返回满足融合属性地和种族战士（不限星级）的卡片，与第一部分组合实现'5星以上 + 任意1只'或'2只均≥5星'等逻辑
function s.matfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 对应原文'不受对方发动的效果影响'的判断条件前半段：判断效果对象的手牌玩家是否与触发效果的持有者不同且该效果为激活状态（IsActivated）
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
		-- 对应原文'不受对方发动的效果影响'的判断条件后半段：限定效果处理必须在主阶段期间才能生效，确保免疫效果仅在主要阶段有效
		and Duel.IsMainPhase()
end
-- 对应原文'可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击'的条件判断函数：检查触发效果的持有者场下是否存在至少1只表侧表示怪兽（IsFaceup），用于决定是否激活强制攻击规则
function s.macon(e)
	-- 同上，直接返回 IsExistingMatchingCard 函数的调用结果，即场上是否有符合条件的目标卡存在
	return Duel.IsExistingMatchingCard(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 对应原文'可以攻击的对方怪兽必须向自己场上攻击力最高的怪兽作出攻击'的目标判断函数：获取持有者场下所有表侧表示怪兽中攻击力最高的一组（GetMaxGroup），并检查当前卡片是否属于该组
function s.atklimit(e,c)
	-- 同上，具体实现为从匹配表中提取攻击力最大的怪兽集合，用于后续 IsContains 校验
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack)
	return g and g:IsContains(c)
end
-- 对应原文'自己场上的其他战士族·地属性怪兽战斗破坏对方怪兽时'的触发条件过滤函数：判断被破坏卡是否为对手控制、非自身效果来源；若由战斗引起则检查是否表侧表示且位于场下怪兽区并仍为对手控制及保持战士族/地属性的种族与属性特征
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
-- 对应原文'自己场上的其他战士族·地属性怪兽战斗破坏对方怪兽时'的触发条件主函数：判断被破坏卡组中是否存在至少一张满足 s.egfilter 条件的卡片（即由符合条件的怪兽战斗破坏对手怪兽）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp,e:GetHandler())
end
-- 对应原文'可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤'的目标选择过滤函数：筛选表侧表示、地为种族且可特殊召唤的战士族/地属性卡，支持从墓地和除外区各选最多1张
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对应原文'可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤'的目标判断逻辑前半段：检查持有者场下是否有可用空格（LOCATION_MZONE>0）以及是否存在至少一张满足 s.spfilter 条件的卡片
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 同上，具体实现为获取 LOCATION_MZONE 区域的可用格子数是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同上，继续与 IsExistingMatchingCard 判断结合，确保目标卡存在于墓地或除外区且数量不超过1张
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 对应原文'可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤'的操作信息设置：将操作分类设为 CATEGORY_SPECIAL_SUMMON，targets 为 nil（不确定具体对象），count=1，target_player 和 target_param 分别为持有者和场下区域
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 对应原文'可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤'的处理函数整体逻辑：先检查是否有可用格子；然后提示玩家选择卡片；接着从墓地和除外区中选择最多1张符合条件的卡（考虑王家长眠之谷影响）进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 同上，具体实现为若场下无空格则提前返回结束处理流程
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 对应原文'可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤'的提示消息设置：向玩家显示选择卡片类型的提示信息（HINT_SELECTMSG）并附带 HINTMSG_SPSUMMON 常量标识
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 同上，具体实现为调用 SelectMatchingCard 函数从墓地和除外区中选择最多1张满足 s.spfilter 且不受王家长眠之谷影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 对应原文'可以把自己墓地·除外状态的1只战士族·地属性怪兽特殊召唤'的最终执行步骤：将选中的卡片组以正面表示方式特殊召唤到持有者场下
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
