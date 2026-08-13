--魔導書院ラメイソン
-- 效果：
-- ①：自己场上或者自己墓地有魔法师族怪兽存在的场合，自己准备阶段才能发动。从自己墓地选「魔导书院 拉迈松」以外的1张「魔导书」魔法卡回到卡组最下面，自己从卡组抽1张。
-- ②：这张卡被对方破坏送去墓地时才能发动。把持有自己墓地的「魔导书」魔法卡数量以下的等级的1只魔法师族怪兽从手卡·卡组特殊召唤。
function c33981008.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上或者自己墓地有魔法师族怪兽存在的场合，自己准备阶段才能发动。从自己墓地选「魔导书院 拉迈松」以外的1张「魔导书」魔法卡回到卡组最下面，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33981008,0))  --"返回卡组并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c33981008.drcon)
	e2:SetTarget(c33981008.drtg)
	e2:SetOperation(c33981008.drop)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方破坏送去墓地时才能发动。把持有自己墓地的「魔导书」魔法卡数量以下的等级的1只魔法师族怪兽从手卡·卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33981008,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c33981008.spcon)
	e3:SetTarget(c33981008.sptg)
	e3:SetOperation(c33981008.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否为魔法师族，且处于墓地或场上表侧表示，用于效果①发动条件中“自己场上或者自己墓地有魔法师族怪兽存在”的判定。
function c33981008.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果①的发动条件：当前回合玩家为自己，且自己场上或墓地存在满足cfilter的魔法师族怪兽。
function c33981008.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为发动者tp的准备阶段，以及自己场上或墓地是否存在魔法师族怪兽（墓地存在或场上表侧表示）。
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c33981008.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 过滤条件：选择“魔导书”字段的魔法卡，且不是「魔导书院 拉迈松」自身，并能够回到卡组，用于效果①返回卡组的对象选择。
function c33981008.filter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(33981008) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 效果①的发动目标：先确认发动时玩家可以抽卡且墓地存在符合条件的“魔导书”魔法卡，再设置回卡组与抽卡的操作信息。
function c33981008.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：玩家能够抽1张卡，且自己墓地存在1张符合条件的「魔导书」魔法卡可供选择返回卡组。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(c33981008.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本效果处理时将从自己墓地选择1张卡返回卡组（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：本效果处理时自己将从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的实际处理：选择1张符合条件的「魔导书」魔法卡返回卡组最下面，若成功则自己抽1张卡。
function c33981008.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家发出提示：选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张满足filter条件的「魔导书」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c33981008.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 显示所选卡片的选中动画，并将其记录为本效果关联的对象。
	Duel.HintSelection(g)
	-- 若成功选择了卡且将其以效果原因送回卡组最下面，则继续执行抽卡。
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		-- 自己以效果原因从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被对方玩家以破坏方式送去墓地，且不是规则破坏。
function c33981008.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and not e:GetHandler():IsReason(REASON_RULE) and rp==1-tp
end
-- 过滤条件：判定墓地中的卡是否为「魔导书」魔法卡，用于计算墓地「魔导书」魔法卡的数量。
function c33981008.ctfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 过滤条件：判定怪兽是否为魔法师族、等级不超过lv，并且可以被效果特殊召唤，用于效果②的候选怪兽。
function c33981008.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标：确认自己场上有主怪兽区空位，计算墓地「魔导书」魔法卡数量作为等级上限，检查手卡·卡组中是否存在符合条件的魔法师族怪兽，并设置特殊召唤的操作信息。
function c33981008.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 发动时检查：自己场上必须有可用的主怪兽区空格，否则不能发动效果②。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 计算自己墓地中「魔导书」魔法卡的数量，作为可特殊召唤怪兽的等级上限。
		local ct=Duel.GetMatchingGroupCount(c33981008.ctfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查手卡·卡组中是否存在等级不高于该数量且可被特殊召唤的魔法师族怪兽。
		return Duel.IsExistingMatchingCard(c33981008.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,ct)
	end
	-- 设置操作信息：本效果处理时将从手卡·卡组特殊召唤1只魔法师族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的实际处理：再次确认主怪兽区空位，计算墓地「魔导书」数量，选择符合条件的魔法师族怪兽并特殊召唤。
function c33981008.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有可用的主怪兽区空格，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 向发动玩家发出提示：选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 处理时再次计算自己墓地中「魔导书」魔法卡的数量，作为等级上限。
	local ct=Duel.GetMatchingGroupCount(c33981008.ctfilter,tp,LOCATION_GRAVE,0,nil)
	-- 从手卡·卡组选择1只满足条件（魔法师族、等级≤ct、可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c33981008.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,ct)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
