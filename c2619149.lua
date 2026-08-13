--剣闘獣サムニテ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「剑斗兽」的卡加入手卡。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 盾斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c2619149.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「剑斗兽」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2619149,0))  --"检索卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c2619149.scon)
	e1:SetTarget(c2619149.stg)
	e1:SetOperation(c2619149.sop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 盾斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2619149,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2619149.spcon)
	e2:SetCost(c2619149.spcost)
	e2:SetTarget(c2619149.sptg)
	e2:SetOperation(c2619149.spop)
	c:RegisterEffect(e2)
end
-- 该条件函数用于判定效果1能否发动：需要本卡带有通过「剑斗兽」怪兽效果特殊召唤成功的标识（flag数量>0），且本卡在本次战斗阶段中战斗破坏了对方怪兽并使其送入墓地（aux.bdogcon）。
function c2619149.scon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查两个条件：本卡持有特殊召唤成功标识（GetFlagEffect>0），并且满足辅助函数aux.bdogcon（与对方怪兽战斗并将其战斗破坏送去墓地）。
	return c:GetFlagEffect(2619149)>0 and aux.bdogcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义检索的过滤函数：选择卡组中卡名带有「剑斗兽」字段且可以被加入手卡的卡。
function c2619149.sfilter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToHand()
end
-- 效果1的发动目标处理：在发动时确认卡组中存在至少1张符合条件的「剑斗兽」卡，然后设置本次操作为从卡组将1张卡加入手卡（CATEGORY_TOHAND）。
function c2619149.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时判定（chk==0），检查卡组中是否存在1张满足sfilter过滤条件的「剑斗兽」卡；存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2619149.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁的效果分类为回手牌，预计把1张卡（不取对象）加入手卡，目标玩家为0（不指定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 效果1的解决处理：让玩家从卡组挑选1张「剑斗兽」卡加入手卡，并让对方确认该卡。
function c2619149.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示，引导玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己的卡组中选出1张符合sfilter条件的「剑斗兽」卡（如果没有则不处理）。
	local g=Duel.SelectMatchingCard(tp,c2619149.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认（防止作弊或确认检索结果）。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果2的发动条件：本卡本回合进行过战斗（GetBattledGroupCount>0），即在战斗阶段结束时可发动。
function c2619149.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果2的代价：将本卡从场上弹回持有者卡组并洗切，作为发动特殊召唤效果的cost。
function c2619149.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将本卡以cost原因送回卡组并洗牌（SEQ_DECKSHUFFLE表示先置于卡组底再洗切）。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义特殊召唤的过滤函数：选择卡组中卡名不是「剑斗兽 盾斗」自身、带有「剑斗兽」字段且可以被当前效果特殊召唤的怪兽。
function c2619149.filter(c,e,tp)
	return not c:IsCode(2619149) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动目标处理：确认主要怪兽区有可用空格（考虑自身作为cost回卡组后会腾出格子），且卡组中存在符合条件的「剑斗兽」怪兽，然后设置特殊召唤的操作信息。
function c2619149.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：我方主要怪兽区的可用格数大于-1（即cost处理后可腾出至少1格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 同时检查卡组中是否存在至少1只满足特殊召唤条件的「剑斗兽」怪兽（排除盾斗自身）。
		and Duel.IsExistingMatchingCard(c2619149.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁的效果分类为特殊召唤，预计特殊召唤1只怪兽到持有者（tp）场上，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果2的解决处理：若主要怪兽区无空位则直接结束；否则选择1只符合条件的「剑斗兽」怪兽特殊召唤，并给它注册自身卡号的标识，表示它是由「剑斗兽」效果特殊召唤成功的怪兽。
function c2619149.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区是否有空位；若没有，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给出选择提示，引导玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的卡组中选出1只符合filter条件的「剑斗兽」怪兽（排除自身）。
	local g=Duel.SelectMatchingCard(tp,c2619149.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到玩家自己场上，不检查召唤条件和苏生限制（false,false），表示形式为表侧表示。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
