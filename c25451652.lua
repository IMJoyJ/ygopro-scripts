--堕天使ルシフェル
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡上级召唤成功的场合才能发动。把最多有对方场上的效果怪兽数量的「堕天使」怪兽从手卡·卡组特殊召唤。
-- ②：只要自己场上有其他的「堕天使」怪兽存在，对方不能把这张卡作为效果的对象。
-- ③：1回合1次，自己主要阶段才能发动。把场上的「堕天使」怪兽数量的卡从自己卡组上面送去墓地。自己回复这个效果送去墓地的「堕天使」卡数量×500基本分。
function c25451652.initial_effect(c)
	-- 效果原文内容：这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡上级召唤成功的场合才能发动。把最多有对方场上的效果怪兽数量的「堕天使」怪兽从手卡·卡组特殊召唤。
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
	-- 效果原文内容：②：只要自己场上有其他的「堕天使」怪兽存在，对方不能把这张卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	-- 规则层面操作：设置效果值为aux.tgoval函数，用于过滤不能成为对方效果对象的条件。
	e3:SetValue(aux.tgoval)
	e3:SetCondition(c25451652.tgcon)
	c:RegisterEffect(e3)
	-- 效果原文内容：③：1回合1次，自己主要阶段才能发动。把场上的「堕天使」怪兽数量的卡从自己卡组上面送去墓地。自己回复这个效果送去墓地的「堕天使」卡数量×500基本分。
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
-- 规则层面操作：判断此卡是否为上级召唤成功 summoned by advance summon。
function c25451652.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 规则层面操作：过滤函数，返回场上正面表示的含效果怪兽。
function c25451652.ctfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 规则层面操作：过滤函数，返回手卡或卡组中可特殊召唤的堕天使怪兽。
function c25451652.spfilter(c,e,tp)
	return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足特殊召唤条件，包括有空场、有对方场上效果怪兽、有可特殊召唤的堕天使怪兽。
function c25451652.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断自己场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断对方场上是否有效果怪兽。
		and Duel.IsExistingMatchingCard(c25451652.ctfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 规则层面操作：判断自己手卡或卡组中是否有堕天使怪兽。
		and Duel.IsExistingMatchingCard(c25451652.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤1张堕天使怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 规则层面操作：执行特殊召唤操作，从手卡或卡组中选择堕天使怪兽进行特殊召唤。
function c25451652.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取对方场上的正面表示的效果怪兽组。
	local g1=Duel.GetMatchingGroup(c25451652.ctfilter,tp,0,LOCATION_MZONE,nil)
	-- 规则层面操作：获取自己手卡或卡组中可特殊召唤的堕天使怪兽组。
	local g2=Duel.GetMatchingGroup(c25451652.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	local ct=5
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 规则层面操作：计算实际可特殊召唤的数量，受青眼精灵龙效果和场上空位限制。
	ct=math.min(ct,g1:GetCount(),(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ct>0 and g2:GetCount()>0 then
		-- 规则层面操作：提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g2:Select(tp,1,ct,nil)
		-- 规则层面操作：将选择的卡特殊召唤到场上。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面操作：过滤函数，返回场上正面表示的堕天使怪兽。
function c25451652.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xef)
end
-- 规则层面操作：判断自己场上是否有其他堕天使怪兽存在。
function c25451652.tgcon(e)
	-- 规则层面操作：判断自己场上是否有其他堕天使怪兽存在。
	return Duel.IsExistingMatchingCard(c25451652.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 规则层面操作：设置发动效果的连锁操作信息，表示将要从卡组丢弃卡并回复基本分。
function c25451652.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：获取自己场上的堕天使怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c25451652.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面操作：判断自己是否可以丢弃指定数量的卡。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 规则层面操作：设置连锁操作信息，表示将要从卡组丢弃指定数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
	-- 规则层面操作：设置连锁操作信息，表示将要回复指定数量的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*500)
end
-- 规则层面操作：过滤函数，返回墓地中堕天使怪兽。
function c25451652.ctfilter2(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0xef)
end
-- 规则层面操作：执行丢弃卡组顶部卡并回复基本分的操作。
function c25451652.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取自己场上的堕天使怪兽数量。
	local ct1=Duel.GetMatchingGroupCount(c25451652.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct1>0 then
		-- 规则层面操作：从自己卡组顶部丢弃指定数量的卡。
		if Duel.DiscardDeck(tp,ct1,REASON_EFFECT)~=0 then
			-- 规则层面操作：获取实际丢弃的卡组。
			local og=Duel.GetOperatedGroup()
			local ct2=og:FilterCount(c25451652.ctfilter2,nil)
			if ct2>0 then
				-- 规则层面操作：回复基本分，数值为丢弃的堕天使怪兽数量乘以500。
				Duel.Recover(tp,ct2*500,REASON_EFFECT)
			end
		end
	end
end
