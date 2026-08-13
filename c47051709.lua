--フォトン・デルタ・ウィング
-- 效果：
-- ①：这张卡召唤的场合才能发动。从手卡·卡组把1只「光子三角翼飞机」守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是光属性怪兽不能特殊召唤。
-- ②：自己场上有其他的「光子三角翼飞机」存在的场合，对方不能攻击宣言。
local s,id,o=GetID()
-- 注册此卡的两个效果：①召唤成功时从手卡·卡组特召同名卡的诱发效果，并在效果处理时给自己附加“直到回合结束时只能特殊召唤光属性怪兽”的自肃；②自己场上有其他表侧表示同名卡存在时，对方不能进行攻击宣言的永续效果。
function s.initial_effect(c)
	-- 这张卡召唤的场合才能发动。从手卡·卡组把1只「光子三角翼飞机」守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 自己场上有其他的「光子三角翼飞机」存在的场合，对方不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为本卡同名卡（卡号id）且能够被当前效果以表侧守备表示特殊召唤（不解除召唤条件/苏生限制）。
function s.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动条件判定：自己场上主要怪兽区存在空位，且手卡·卡组中存在至少1张满足过滤条件的同名卡可被特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查之一：自己场上主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查之二：检查手卡·卡组是否存在至少1张满足s.filter（同名且可被表侧守备特召）的卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向连锁系统登记本次效果的操作信息：本效果属于特殊召唤，预定从手卡·卡组特殊召唤1只怪兽（对象在处理时选择），供其他卡检测此效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：若自己场上主要怪兽区有空位，则从手卡·卡组选择1张同名卡以表侧守备表示特殊召唤；然后给自己附加自肃效果——直到回合结束时，自己不能特殊召唤光属性以外的怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上主要怪兽区是否仍有可用空格，防止发动后场地被其他连锁占用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给操作玩家显示特殊召唤的选卡提示信息“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的手卡·卡组中选出1张满足过滤条件（同名且可特召）的卡，作为本次特殊召唤的对象。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的卡以表侧守备表示特殊召唤到自己场上（仍会检查该卡的召唤条件和苏生限制，但筛选函数已保证满足）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时自己不是光属性怪兽不能特殊召唤。自己场上有其他的「光子三角翼飞机」存在的场合，对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 将不能特殊召唤的对象限定为属性非光属性的怪兽（即禁止特殊召唤非光属性怪兽）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsNonAttribute,ATTRIBUTE_LIGHT))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家tp，使该效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：卡片为表侧表示且卡名为「光子三角翼飞机」（卡号id），用于查找场上存在的其他同名卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
-- 效果②的适用条件：自己场上是否存在除本卡以外的其他表侧表示同名卡（「光子三角翼飞机」）。
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 返回真值：在自己场上（主要怪兽区·魔陷区）存在至少1张除效果持有者自身以外的表侧表示同名卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
