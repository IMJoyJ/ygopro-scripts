--ダンディ・ホワイトライオン
-- 效果：
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。
-- ①：这张卡从手卡·场上送去墓地的场合才能发动。在自己场上把3只「白绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化效果：创建并注册①效果（这张卡从手卡·场上送去墓地的场合才能发动，在自己场上特殊召唤3只「白绵毛衍生物」），设定同名卡效果1回合1次；同时注册特殊召唤活动计数器，用于自肃判定（本回合从额外卡组特殊召唤的次数）。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。①：这张卡从手卡·场上送去墓地的场合才能发动。在自己场上把3只「白绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 注册一个代号为id的特殊召唤活动计数器，记录本回合从额外卡组特殊召唤怪兽的次数；供s.spcost检查自肃条件。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：若特殊召唤的怪兽不是从额外卡组特殊召唤则返回true（不计入限制次数）；若从额外卡组特殊召唤则返回false（计数器+1），以此记录额外卡组特招行为。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果发动条件：这张卡是从手卡或场上被送去墓地的场合（即之前位置为手牌或场上区域）。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 效果发动代价：先通过自肃计数器检查本回合尚未进行过从额外卡组的特殊召唤；然后给己方玩家tp注册一个誓约效果，使本回合内不能从额外卡组把怪兽特殊召唤。该誓约效果于结束阶段重置。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：判断本回合己方从额外卡组特殊召唤的发生次数是否为0，若为0才允许发动效果。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，自己不能从额外卡组把怪兽特殊召唤。①：这张卡从手卡·场上送去墓地的场合才能发动。在自己场上把3只「白绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将刚创建的自肃效果e1注册到玩家tp，使其立刻生效：该回合内tp不能从额外卡组特殊召唤怪兽；效果在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤函数：当尝试特殊召唤的怪兽位于额外卡组时返回true，从而禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 效果发动目标与可行性判定：要求己方主要怪兽区域至少3个空格、己方未受青眼精灵龙影响（不能同时特殊召唤2只以上怪兽）、且能够特殊召唤白绵毛衍生物；满足后设置操作信息为特殊召唤3只衍生物。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有至少3个可用空格，以保证能一次特殊召唤3只衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家tp能够以表侧守备表示特殊召唤1只白绵毛衍生物（植物族·风·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,36629636,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次效果处理时将生成3只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置操作信息：本次效果处理时将进行3只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理时再次确认：若己方主要怪兽区域空格不足3个，或己方受到青眼精灵龙效果影响（禁止同时特殊召唤2只以上怪兽），则不进行特殊召唤处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区域空格数小于3，则无法让3只衍生物同时上场，终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 再次确认玩家tp当前仍能特殊召唤白绵毛衍生物；若因其他效果限制无法特殊召唤，则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,36629636,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	for i=1,3 do
		-- 创建1只白绵毛衍生物（卡号36629636）的衍生物卡。
		local token=Duel.CreateToken(tp,36629636)
		-- 将这只白绵毛衍生物以表侧守备表示加入特殊召唤处理（作为多次特殊召唤的一步，等待与其余衍生物一起完成）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 完成本次连锁中的特殊召唤步骤，统一处理3只衍生物特殊召唤成功后的时点与效果。
	Duel.SpecialSummonComplete()
end
