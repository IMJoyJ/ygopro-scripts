--堕天使ルシフェル
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡上级召唤成功的场合才能发动。把最多有对方场上的效果怪兽数量的「堕天使」怪兽从手卡·卡组特殊召唤。
-- ②：只要自己场上有其他的「堕天使」怪兽存在，对方不能把这张卡作为效果的对象。
-- ③：1回合1次，自己主要阶段才能发动。把场上的「堕天使」怪兽数量的卡从自己卡组上面送去墓地。自己回复这个效果送去墓地的「堕天使」卡数量×500基本分。
function c25451652.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：这张卡上级召唤成功的场合才能发动。把最多有对方场上的效果怪兽数量的「堕天使」怪兽从手卡·卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25451652,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c25451652.spcon)
	e2:SetTarget(c25451652.sptg)
	e2:SetOperation(c25451652.spop)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有其他的「堕天使」怪兽存在，对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	-- 为②效果设置值为aux.tgoval：该函数是标准的“不会成为对方的效果对象”的判定函数，使此卡在满足条件时不能被对方效果指定为对象。
	e3:SetValue(aux.tgoval)
	e3:SetCondition(c25451652.tgcon)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。把场上的「堕天使」怪兽数量的卡从自己卡组上面送去墓地。自己回复这个效果送去墓地的「堕天使」卡数量×500基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25451652,1))
	e4:SetCategory(CATEGORY_DECKDES+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c25451652.distg)
	e4:SetOperation(c25451652.disop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：判定这张卡是否是以“上级召唤”的方式召唤成功。
function c25451652.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数：判断怪兽是否为表侧表示且为效果怪兽，用于统计对方场上的效果怪兽数量。
function c25451652.ctfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 过滤函数：判断怪兽是否属于「堕天使」字段且能够被特殊召唤，用于从手卡·卡组中筛选可特殊召唤的堕天使怪兽。
function c25451652.spfilter(c,e,tp)
	return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动合法性检测：必须同时满足主怪兽区有空位、对方场上有表侧效果怪兽、自己手卡·卡组有可特殊召唤的堕天使怪兽，才能发动。
function c25451652.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查之一：自己场上存在可供特殊召唤使用的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查之一：对方场上存在至少1只表侧表示的效果怪兽，用于决定特殊召唤数量的上限。
		and Duel.IsExistingMatchingCard(c25451652.ctfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 发动条件检查之一：自己手卡或卡组中至少存在1只可以特殊召唤的堕天使怪兽。
		and Duel.IsExistingMatchingCard(c25451652.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本效果的操作信息，宣告将要把堕天使怪兽从手卡·卡组特殊召唤，供其他效果（如青眼精灵龙）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果处理：以对方场上表侧效果怪兽数量为基准，结合己方可用的怪兽区域数和青眼精灵龙的效果（若适用则限制为1只），从手卡·卡组选择1～该数量的堕天使怪兽表侧表示特殊召唤。
function c25451652.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上全部表侧效果怪兽的集合，用于计算可特殊召唤的数量上限。
	local g1=Duel.GetMatchingGroup(c25451652.ctfilter,tp,0,LOCATION_MZONE,nil)
	-- 取得自己手卡·卡组中满足可特殊召唤条件的堕天使怪兽集合，作为可供选择的特殊召唤对象。
	local g2=Duel.GetMatchingGroup(c25451652.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local ct=5
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 实际可特殊召唤数量取预设上限、对方表侧效果怪兽数量、己方可用怪兽区数量三者的最小值。
	ct=math.min(ct,g1:GetCount(),(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ct>0 and g2:GetCount()>0 then
		-- 弹出卡片选择提示，让己方玩家从符合条件的堕天使怪兽中选择要特殊召唤的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g2:Select(tp,1,ct,nil)
		-- 将选中的堕天使怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断怪兽是否表侧表示且属于「堕天使」字段，用于②效果的适用条件检查和③效果的计数。
function c25451652.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xef)
end
-- ②效果的适用条件：自己场上存在除这张卡以外的其他表侧表示「堕天使」怪兽。
function c25451652.tgcon(e)
	-- 检查自己场上除这张卡以外是否存在至少1只表侧表示的「堕天使」怪兽。
	return Duel.IsExistingMatchingCard(c25451652.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- ③效果的发动条件与操作信息设定：统计场上「堕天使」怪兽数量作为从卡组送去墓地的张数；发动时确认卡组足够，并声明卡组送墓与回复LP的操作信息。
function c25451652.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计双方场上表侧表示且属于「堕天使」字段的怪兽数量，以决定要从卡组顶端送去墓地的卡牌数量。
	local ct=Duel.GetMatchingGroupCount(c25451652.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 发动时检测己方卡组是否确实有ct张卡可以送去墓地，若不足则③效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 声明本效果包含把己方卡组顶端ct张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
	-- 声明本效果包含回复LP的操作信息，预置回复量为ct×500。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
-- 过滤函数：判断卡片是否位于墓地且属于「堕天使」字段，用于统计本次效果送去墓地的堕天使卡数量。
function c25451652.ctfilter2(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0xef)
end
-- ③效果处理：按当前场上「堕天使」怪兽数量从卡组顶端把相应张数送去墓地；若实际送墓成功，则统计其中「堕天使」卡的数量，每张回复500基本分。
function c25451652.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新统计双方场上表侧表示的「堕天使」怪兽数量，作为本次从卡组送去墓地的张数。
	local ct1=Duel.GetMatchingGroupCount(c25451652.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct1>0 then
		-- 将己方卡组最上方ct1张卡以效果原因送去墓地；若实际送去墓地的卡数不为0，则继续后续的回复处理。
		if Duel.DiscardDeck(tp,ct1,REASON_EFFECT)~=0 then
			-- 取得刚刚因效果从卡组送去墓地的全体卡片。
			local og=Duel.GetOperatedGroup()
			local ct2=og:FilterCount(c25451652.ctfilter2,nil)
			if ct2>0 then
				-- 按照本次效果送去墓地的堕天使卡片数量，每张回复500基本分。
				Duel.Recover(tp,ct2*500,REASON_EFFECT)
			end
		end
	end
end
