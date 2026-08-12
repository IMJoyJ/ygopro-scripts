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
-- 用于检测自己场上或墓地是否存在魔法师族怪兽的过滤函数
function c33981008.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 判断是否满足效果①的发动条件：自己回合且自己场上或墓地存在魔法师族怪兽
function c33981008.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果①的发动条件：自己回合且自己场上或墓地存在魔法师族怪兽
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c33981008.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 用于筛选墓地中「魔导书」魔法卡的过滤函数（排除自身）
function c33981008.filter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(33981008) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 设置效果①的发动时点处理信息：准备阶段发动，目标为从墓地选1张「魔导书」魔法卡返回卡组并抽1张卡
function c33981008.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断效果①是否可以发动：玩家可以抽卡且墓地存在满足条件的「魔导书」魔法卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(c33981008.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果①的处理信息：将1张卡从墓地返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置效果①的处理信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的处理函数：选择1张卡返回卡组最底端并抽1张卡
function c33981008.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的「魔导书」魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1张「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c33981008.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 显示所选卡的动画效果
	Duel.HintSelection(g)
	-- 判断是否成功将卡返回卡组并执行抽卡
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		-- 执行抽卡效果
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断是否满足效果②的发动条件：该卡被对方破坏送去墓地
function c33981008.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and not e:GetHandler():IsReason(REASON_RULE) and rp==1-tp
end
-- 用于统计墓地中「魔导书」魔法卡数量的过滤函数
function c33981008.ctfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL)
end
-- 用于筛选满足等级要求的魔法师族怪兽的过滤函数
function c33981008.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果②的发动时点处理信息：墓地时发动，目标为从手卡或卡组特殊召唤1只魔法师族怪兽
function c33981008.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断是否满足效果②的发动条件：场上存在召唤空间
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 统计墓地中「魔导书」魔法卡的数量
		local ct=Duel.GetMatchingGroupCount(c33981008.ctfilter,tp,LOCATION_GRAVE,0,nil)
		-- 判断是否满足效果②的发动条件：手卡或卡组存在满足等级要求的魔法师族怪兽
		return Duel.IsExistingMatchingCard(c33981008.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,ct)
	end
	-- 设置效果②的处理信息：从手卡或卡组特殊召唤1只魔法师族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的处理函数：选择1只魔法师族怪兽特殊召唤
function c33981008.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足效果②的发动条件：场上存在召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 提示玩家选择要特殊召唤的魔法师族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 统计墓地中「魔导书」魔法卡的数量
	local ct=Duel.GetMatchingGroupCount(c33981008.ctfilter,tp,LOCATION_GRAVE,0,nil)
	-- 选择满足等级要求的1只魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c33981008.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,ct)
	if g:GetCount()>0 then
		-- 执行特殊召唤效果
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
