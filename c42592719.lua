--剣闘獣アレクサンデル
-- 效果：
-- 「剑斗兽 双斗」以外的效果不能把这张卡特殊召唤。特殊召唤的这张卡只要在自己场上表侧表示存在，不受魔法的效果的影响。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 亚历山大」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c42592719.initial_effect(c)
	-- 特殊召唤的这张卡只要在自己场上表侧表示存在，不受魔法的效果的影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c42592719.imcon)
	e1:SetValue(c42592719.imfilter)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 亚历山大」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42592719,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c42592719.spcon)
	e2:SetCost(c42592719.spcost)
	e2:SetTarget(c42592719.sptg)
	e2:SetOperation(c42592719.spop)
	c:RegisterEffect(e2)
	-- 「剑斗兽 双斗」以外的效果不能把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c42592719.splimit)
	c:RegisterEffect(e3)
end
-- 判断此卡能否被特殊召唤：若发动特殊召唤的效果的来源卡是「剑斗兽 双斗」(31247589) 或召唤类型为灵摆召唤，则允许特殊召唤；否则禁止。
function c42592719.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(31247589) or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 免疫效果的发动条件：只有当此卡是特殊召唤成功而出现在场上时（召唤类型为特殊召唤），其魔法免疫效果才会适用。
function c42592719.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 免疫过滤器：对于要施加于此卡的效果，仅当该效果为魔法卡类型时，此卡才不受其影响；即实现对魔法效果的免疫。
function c42592719.imfilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 诱发效果的发动条件：这张卡本回合进行过战斗（有战斗对象）时，在战斗阶段结束时可以发动。
function c42592719.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 发动代价：将这张卡返回持有者卡组并洗切作为代价；在检查代价阶段仅确认此卡可以作为代价返回卡组。
function c42592719.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 执行代价：将这张卡送入持有者卡组并洗牌（SEQ_DECKSHUFFLE），以 REASON_COST 作为代价处理。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 筛选卡组中符合条件的怪兽：卡名不是「剑斗兽 亚历山大」(42592719)，属于「剑斗兽」系列(0x1019)，且可以被当前效果特殊召唤。
function c42592719.filter(c,e,tp)
	return not c:IsCode(42592719) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的合法性检查：在发动前确认我方怪兽区存在可用的空格（考虑此卡回卡组后腾出格子），且卡组中存在至少1只满足条件的「剑斗兽」怪兽。
function c42592719.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区空格：Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 表示即便这张卡当前占用1格，回到卡组后也能空出位置；若有空格数大于 -1 才可能特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1张满足 c42592719.filter 条件的剑斗兽怪兽，且该卡可被当前效果特殊召唤。
		and Duel.IsExistingMatchingCard(c42592719.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记操作信息：本效果预定将1张卡从卡组特殊召唤到 tp 的怪兽区；因不取对象，目标暂设为 nil，用于后续连锁反应判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若仍有空位，则提示玩家选择卡组中的1只符合条件的剑斗兽怪兽并特殊召唤；召唤成功后再为该怪兽登记一个以原卡号为编号的标记效果，用于状态管理。
function c42592719.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认怪兽区空格，若没有可用的怪兽区则本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示消息为‘请选择要特殊召唤的卡’，用于接下来的选卡操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组中选择1张满足 filter 条件的剑斗兽怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c42592719.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到玩家自己场上（不额外检查召唤条件与苏生限制，按常规方式处理）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
