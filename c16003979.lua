--剣闘獣サジタリィ
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从手卡丢弃1张「剑斗兽」卡才能发动。自己从卡组抽2张。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 射斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c16003979.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，从手卡丢弃1张「剑斗兽」卡才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16003979,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果①的发动条件：此卡用「剑斗兽」怪兽的效果特殊召唤成功时才能发动（使用剑斗兽通用特殊召唤条件判定）。
	e1:SetCondition(aux.gbspcon)
	e1:SetCost(c16003979.drcost)
	e1:SetTarget(c16003979.drtg)
	e1:SetOperation(c16003979.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 射斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16003979,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c16003979.spcon)
	e2:SetCost(c16003979.spcost)
	e2:SetTarget(c16003979.sptg)
	e2:SetOperation(c16003979.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中的「剑斗兽」卡且可以被丢弃，用于①的cost检索条件。
function c16003979.drcfilter(c)
	return c:IsSetCard(0x1019) and c:IsDiscardable()
end
-- 效果①的代价函数：先检查手卡是否存在1张可丢弃的「剑斗兽」卡，若存在则丢弃1张作为发动代价。
function c16003979.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否存在至少1张满足「剑斗兽」字段且可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16003979.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行丢弃：从手卡选1张「剑斗兽」卡丢弃，丢弃理由为代价（REASON_COST）并计入丢弃。
	Duel.DiscardHand(tp,c16003979.drcfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 效果①的目标设定函数：确认自己可以抽2张卡，并把抽卡玩家和抽卡数记录为连锁信息。
function c16003979.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认发动玩家tp可以进行抽2张卡的效果（不受“不能抽卡”限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将此效果的对象玩家设定为发动玩家tp（即自己抽卡）。
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设定为2，表示要抽2张卡。
	Duel.SetTargetParam(2)
	-- 登记操作信息：声明本连锁将执行抽卡效果，目标玩家为tp，预计抽2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果①的处理函数：从连锁信息中取出之前设定的对象玩家和抽卡数，执行抽卡。
function c16003979.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和参数（即抽卡玩家和抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果②的发动条件：此卡在本战斗阶段进行过战斗（存在战斗记录）。
function c16003979.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果②的代价函数：确认此卡可以作为代价回到持有者卡组，实际处理时将自身回到持有者卡组并洗牌。
function c16003979.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将此卡从场上送回持有者卡组，并以洗牌方式处理（代价）。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 筛选卡组中的怪兽：不是「剑斗兽 射斗」自身、是「剑斗兽」字段怪兽且可以被特殊召唤。
function c16003979.filter(c,e,tp)
	return not c:IsCode(16003979) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标设定函数：确认此卡离场后自己仍有可用怪兽区空格，且卡组存在符合条件的剑斗兽怪兽，然后登记特殊召唤信息。
function c16003979.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上在此卡回到卡组后是否有可用的怪兽区空格（>0）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时检查卡组是否存在至少1只满足「剑斗兽 射斗」以外、剑斗兽字段、可特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c16003979.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：声明本连锁将执行特殊召唤效果，从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数：若没有可用的怪兽区则直接结束；否则提示选择，从卡组选1只符合条件的剑斗兽怪兽表侧攻击表示特殊召唤，并给特召的怪兽注册一个标志（剑斗兽通用处理，用于标记该次特殊召唤）。
function c16003979.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上当前没有可用的怪兽区空格，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的剑斗兽怪兽（自动过滤）。
	local g=Duel.SelectMatchingCard(tp,c16003979.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上，不检查召唤条件（因为filter已检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
