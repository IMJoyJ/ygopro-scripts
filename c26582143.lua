--剣闘獣ギステル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只「剑斗兽」怪兽给对方观看才能发动。那2只特殊召唤。
-- ②：这张卡用「剑斗兽」怪兽的效果特殊召唤的场合才能发动。从卡组把1张「剑斗」魔法·陷阱卡加入手卡。
-- ③：这张卡进行战斗的战斗阶段结束时，让这张卡回到卡组才能发动。从卡组把「剑斗兽 师斗」以外的1只「剑斗兽」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：为「剑斗兽 师斗」注册①手牌起动效果（展示自身和另一只剑斗兽特殊召唤）、②以剑斗兽怪兽效果特殊召唤成功时检索「剑斗」魔陷的效果、③战斗阶段结束时自身回卡组特召卡组剑斗兽的效果；①和②分别用不同code设置同名卡1回合1次。
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只「剑斗兽」怪兽给对方观看才能发动。那2只特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡用「剑斗兽」怪兽的效果特殊召唤的场合才能发动。从卡组把1张「剑斗」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索魔陷"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：此卡是用「剑斗兽」怪兽的效果特殊召唤的场合（aux.gbspcon判断召唤类型为剑斗兽专用特召）。
	e2:SetCondition(aux.gbspcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时，让这张卡回到卡组才能发动。从卡组把「剑斗兽 师斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spcon2)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 费用过滤函数：筛选手卡中1只「剑斗兽」怪兽，要求是怪兽卡、未公开、且能以剑斗兽召唤方式被特殊召唤；用于①效果展示并一同特召。
function s.costfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_GLADIATOR,tp,false,false)
end
-- ①效果的发动代价检查：确认手卡中存在符合条件的另一只「剑斗兽」怪兽，且这张卡本身未公开（chk==0合法性判定阶段）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：手卡中是否存在除自身以外的1只满足s.costfilter的「剑斗兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,e,tp)
		and not c:IsPublic() end
	-- 弹出‘请选择给对方确认的卡’的选择提示，用于从手卡选择要展示的「剑斗兽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡中选择1只满足s.costfilter的「剑斗兽」怪兽，作为展示给对方并参与特殊召唤的对象。
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,e,tp):GetFirst()
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sc)
	-- 展示后洗切手卡，避免手卡顺序信息泄露。
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①效果的目标检查：确认自己主要怪兽区空位>1、自身可被特殊召唤，且当前没有‘双方不能把2只以上的怪兽同时特殊召唤’的限制效果（如青眼精灵龙）生效。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有至少2个可用空格，用于同时特殊召唤2只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：预计从手卡特殊召唤2只怪兽（targets为nil表示处理时确定对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 特殊召唤处理时的过滤：筛选出与发动效果仍有关联且能以剑斗兽召唤方式特殊召唤的怪兽。
function s.spopfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_GLADIATOR,tp,false,false)
end
-- ①效果处理：若主要怪兽区空位仍>1，将这张卡与之前选择的那只怪兽组成一组，过滤出仍与效果关联且可特召的2只；确认没有禁止同时特召2只的限制后，以剑斗兽召唤方式将它们表侧表示特殊召唤，并为每只召唤成功的怪兽注册原始卡号flag。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认主要怪兽区空位>1，防止连锁中空格不足导致无法处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(s.spopfilter,nil,e,tp)
	if fg:GetCount()~=2 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 将fg中的2只怪兽以剑斗兽召唤方式（SUMMON_VALUE_GLADIATOR）特殊召唤到己方场上，表侧表示。
	Duel.SpecialSummon(fg,SUMMON_VALUE_GLADIATOR,tp,tp,false,false,POS_FACEUP)
	-- 遍历fg中的每张怪兽，对每只召唤成功的怪兽执行后续的flag注册处理。
	for tc in aux.Next(fg) do
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
-- ②效果检索过滤：从卡组选择1张「剑斗」（0x19）字段的魔法·陷阱卡，且该卡能被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标检查：确认卡组中存在至少1张满足s.thfilter的「剑斗」魔法·陷阱卡，并登记检索加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「剑斗」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：预计从卡组将1张卡加入手卡（用于连锁判定等）。其中targets为nil表示处理时选定具体卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：玩家从卡组选择1张「剑斗」魔陷，加入手卡，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出‘请选择要加入手牌的卡’的提示，用于卡组检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中检索选择1张满足s.thfilter的「剑斗」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，操作原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果发动条件：这张卡在本战斗阶段中进行过战斗（存在战斗记录）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ③效果的发动代价：将这张卡从场上返回卡组并洗切，作为发动代价的合法性检查与执行（chk==0时只检查可送回卡组）。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将这张卡从场上送去卡组并洗切，作为③效果的发动代价（REASON_COST）。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ③效果特殊召唤过滤：从卡组中筛选「剑斗兽 师斗」以外的「剑斗兽」怪兽，且该怪兽能被特殊召唤。
function s.spfilter2(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标检查：确认考虑自身离开后主要怪兽区仍有至少1个空位，且卡组中存在符合条件的「剑斗兽」怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查主要怪兽区（考虑这张卡返回卡组后）是否有至少1个可用空格。
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 且卡组中存在1只符合条件的「剑斗兽」怪兽（非「剑斗兽 师斗」，且可特殊召唤）。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：预计从卡组特殊召唤1只怪兽（targets为nil表示处理时确定对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：再次确认主要怪兽区有空位后，从卡组选择1只符合条件的「剑斗兽」怪兽表侧表示特殊召唤，并为召唤成功的怪兽注册原始卡号flag。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时确认主要怪兽区仍有至少1个空位，防止处理时空格不足。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出‘请选择要特殊召唤的卡’的提示，用于从卡组选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足s.spfilter2的「剑斗兽」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「剑斗兽」怪兽以表侧表示特殊召唤到己方场上（sumtype为0，即不限定特殊召唤方式）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
