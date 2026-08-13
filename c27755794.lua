--絢嵐たるメガラ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地有「旋风」存在的场合或者对方场上没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「绚岚」速攻魔法卡或「旋风」发动的场合才能发动。同名怪兽不在自己场上存在的1只「绚岚」怪兽从卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册该卡的两个效果：①以规则型特殊召唤手续让这张卡满足条件时从手卡特殊召唤；②在场上时，当「绚岚」速攻魔法或「旋风」发动后，从卡组特殊召唤1只「绚岚」怪兽并附加风属性自肃。
function s.initial_effect(c)
	-- 将卡号5318639（旋风）登记为这张卡文本中记载的卡名，以便相关判定和提示能够识别该卡名。
	aux.AddCodeList(c,5318639)
	-- 对应①效果：「这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己墓地有「旋风」存在的场合或者对方场上没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。」此处将其实现为无种类规则效果（EFFECT_SPSUMMON_PROC），仅在手牌生效，并带有1回合1次的誓约计数。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 对应②效果：「这个卡名的②的效果1回合只能使用1次。②：「绚岚」速攻魔法卡或「旋风」发动的场合才能发动。同名怪兽不在自己场上存在的1只「绚岚」怪兽从卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。」此处实现为在场上且连锁魔法发动时触发的诱发效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①特殊召唤手续的条件函数：先确认有可用怪兽区，再判断是否满足‘对方场上没有魔法·陷阱卡’或‘自己墓地有「旋风」’两个条件之一，二者均满足也可。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查要特殊召唤的这张卡的控制者是否有空余的主要怪兽区。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上不存在魔法·陷阱卡（即不存在任何魔法·陷阱卡时，满足①的条件之一）。
		and (not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查自己墓地是否存在卡名包含「旋风」（5318639）的卡，满足①的另一个条件。
		or Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,1,nil,5318639))
end
-- ②的发动时机判断：本次连锁发动的必须是魔法·陷阱卡的‘卡的发动’（EFFECT_TYPE_ACTIVATE），且该卡是「旋风」（5318639），或者是「绚岚」字段的速攻魔法卡。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and (re:GetHandler():IsCode(5318639)
		or re:GetHandler():IsSetCard(0x1d1) and re:IsActiveType(TYPE_QUICKPLAY))
end
-- 定义候选怪兽的过滤条件：怪兽属于「绚岚」字段，能够被当前效果特殊召唤，并且自己场上不存在与其同名的表侧表示怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上不存在表侧表示且与候选卡同名的怪兽，以满足‘同名怪兽不在自己场上存在’的限定。
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
-- ②的发动条件和对象设定阶段：仅在条件检查时确认自己主要怪兽区有空位，并且卡组中存在符合条件的「绚岚」怪兽；该效果不取对象，特殊召唤的对象在处理时选择。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足s.spfilter过滤条件的「绚岚」怪兽，作为发动条件之一。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁的操作信息：预计从卡组把1只怪兽特殊召唤，供后续连锁判定或相关卡片响应时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：先处理特殊召唤（若有空位则从卡组选1只符合条件的「绚岚」怪兽正面表示特殊召唤），然后给当前玩家附加直到回合结束为止不能特殊召唤风属性以外怪兽的自肃效果。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍存在可用怪兽区，防止发动后格子被其他卡占用导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出选择提示，让玩家从卡组中选择要特殊召唤的「绚岚」怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1张满足s.spfilter条件的「绚岚」怪兽（过滤条件中已包含可特殊召唤和场上无同名怪兽）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区（sumtype为0，nocheck/nolimit为false，表示沿用常规合法性检查）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果注册到当前回合玩家tp身上，使其在阶段结束前受到特殊召唤限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤函数：如果待特殊召唤的怪兽不是风属性（ATTRIBUTE_WIND），则禁止该特殊召唤。
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
