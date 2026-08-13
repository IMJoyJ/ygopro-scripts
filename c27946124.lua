--聖蔓の社
-- 效果：
-- 自己场上有「圣天树」连接怪兽存在的场合，把1张手卡送去墓地才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，自己不是植物族怪兽不能从额外卡组特殊召唤。
-- ②：1回合1次，可以发动。从自己墓地选1只4星以下的植物族通常怪兽特殊召唤。
-- ③：对方结束阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1张永续陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
function c27946124.initial_effect(c)
	-- 自己场上有「圣天树」连接怪兽存在的场合，把1张手卡送去墓地才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27946124.cost)
	e1:SetCondition(c27946124.con)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不是植物族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c27946124.splimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，可以发动。从自己墓地选1只4星以下的植物族通常怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27946124,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c27946124.sptg)
	e3:SetOperation(c27946124.spop)
	c:RegisterEffect(e3)
	-- ③：对方结束阶段，把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地1张永续陷阱卡为对象才能发动。那张卡在自己的魔法与陷阱区域盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27946124,1))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCost(c27946124.setcost)
	e4:SetCondition(c27946124.setcon)
	e4:SetTarget(c27946124.settg)
	e4:SetOperation(c27946124.setop)
	c:RegisterEffect(e4)
end
-- 发动代价的检查与执行：确认手卡中存在可作为代价送去墓地的卡后，选择1张手卡丢弃（送去墓地）作为发动代价。
function c27946124.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己的手卡中是否存在至少1张能够作为代价送去墓地的卡（候选排除e:GetHandler()自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手卡选择1张能够作为代价送去墓地的卡，以REASON_COST（代价）为由丢弃（送去墓地）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 筛选函数：判断卡片是否为表侧表示的连接怪兽且属于「圣天树」系列（0x2158），用于检查场上是否存在「圣天树」连接怪兽。
function c27946124.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x2158)
end
-- 发动条件：自己场上存在至少1只满足cfilter的怪兽（表侧表示的「圣天树」连接怪兽）时，才允许发动此卡。
function c27946124.con(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上（LOCATION_MZONE）是否存在至少1只表侧表示且属于「圣天树」系列的连接怪兽。
	return Duel.IsExistingMatchingCard(c27946124.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤限制判定：当要从额外卡组特殊召唤怪兽时，若该怪兽不是植物族，则禁止特殊召唤，即从额外卡组只能特殊召唤植物族怪兽。
function c27946124.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_PLANT)
end
-- 特殊召唤候选筛选：目标必须是4星以下的植物族通常怪兽，并且能够被当前效果特殊召唤（检查召唤条件和苏生限制）。
function c27946124.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件的判定：确认存在可用怪兽区空格，且墓地存在至少1只满足spfilter条件的植物族通常怪兽。
function c27946124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查之一：自己场上是否有可用的主要怪兽区空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件检查之二：自己墓地是否存在至少1只满足spfilter条件的植物族通常怪兽。
		and Duel.IsExistingMatchingCard(c27946124.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：宣告该效果包含特殊召唤，将会有1只怪兽从持有者tp的墓地特殊召唤（具体对象在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：再次确认空格后，提示玩家选择要特殊召唤的卡；从自己墓地选择1只符合条件的植物族通常怪兽（过滤受王家长眠之谷影响的卡），将其表侧表示特殊召唤到自己场上。
function c27946124.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时二次确认：若此时自己场上已没有可用的主要怪兽区空格，则终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter的植物族通常怪兽（通过aux.NecroValleyFilter排除受王家长眠之谷影响的卡），结果存入g。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27946124.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到tp场上（sumtype=0，不跳过召唤条件和苏生限制的检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动代价：把这张卡自身送去墓地作为代价。包含代价的检查与执行。
function c27946124.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价：将这张卡自身以REASON_COST（代价）为由从魔法与陷阱区域送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ③效果发动条件：只能在对方回合（结束阶段）发动，通过判断当前玩家tp不是回合玩家来确定。
function c27946124.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回tp是否为非回合玩家（即tp不是当前回合玩家时返回真，满足在对方结束阶段发动的条件）。
	return tp~=Duel.GetTurnPlayer()
end
-- 对象筛选：目标必须是永续陷阱卡（同时满足永续类型和陷阱类型），且当前可以被盖放（IsSSetable(true)）。
function c27946124.setfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsSSetable(true)
end
-- ③效果的目标/发动条件判定：先验证连锁中选定的对象是否合法（chkc），再在chk==0时检查自己魔陷区是否有空位以及墓地是否存在至少1张符合条件的永续陷阱卡可作为对象。
function c27946124.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27946124.setfilter(chkc) end
	-- 检查自己魔法与陷阱区域是否存在可用的空格（计算时排除e:GetHandler()自身），用于之后盖放对象。
	if chk==0 then return Duel.GetSZoneCount(tp,e:GetHandler())>0
		-- 检查自己墓地是否存在至少1张可以作为对象且符合setfilter的永续陷阱卡。
		and Duel.IsExistingTarget(c27946124.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示：请选择要盖放的卡（HINTMSG_SET）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己墓地选择1张符合条件的永续陷阱卡作为效果对象，并登记为当前连锁的取对象目标。
	local sg=Duel.SelectTarget(tp,c27946124.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：该效果会使对象卡离开墓地（CATEGORY_LEAVE_GRAVE），用于系统检测，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
end
-- ③效果处理：取得连锁对象卡，若该卡仍与本次效果关联（未被移动等），则将其盖放到自己的魔法与陷阱区域。
function c27946124.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本次连锁的处理对象（即被指定的墓地永续陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡盖放到自己的魔法与陷阱区域（只盖放，不发动）。
		Duel.SSet(tp,tc)
	end
end
