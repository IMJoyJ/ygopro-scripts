--聖騎士の三兄弟
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把最多2只「圣骑士」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能特殊召唤。
-- ②：这张卡在自己场上的怪兽是「圣骑士」怪兽3只的场合才能攻击。
-- ③：1回合1次，以自己墓地的「圣骑士」卡以及「圣剑」卡合计3张为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c57690191.initial_effect(c)
	-- ②：这张卡在自己场上的怪兽是「圣骑士」怪兽3只的场合才能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c57690191.atcon)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从手卡把最多2只「圣骑士」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57690191,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c57690191.sptg)
	e2:SetOperation(c57690191.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，以自己墓地的「圣骑士」卡以及「圣剑」卡合计3张为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57690191,1))  --"卡片回收"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c57690191.drtg)
	e3:SetOperation(c57690191.drop)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
end
-- 攻击限制条件：当自己场上的怪兽数量不等于3，或者存在里侧表示或非「圣骑士」怪兽时，此卡不能攻击
function c57690191.atcon(e)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	return g:GetCount()~=3 or g:IsExists(c57690191.atkfilter,1,nil)
end
-- 过滤条件：里侧表示怪兽，或者不是「圣骑士」字段的怪兽
function c57690191.atkfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x107a)
end
-- 过滤条件：手卡中可以特殊召唤的「圣骑士」怪兽
function c57690191.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查自己场上是否有空位，以及手卡中是否存在可特殊召唤的「圣骑士」怪兽，并设置特殊召唤的操作信息
function c57690191.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只满足特殊召唤条件的「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(c57690191.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：在有可用怪兽区域时，从手卡特殊召唤最多2只「圣骑士」怪兽，并注册直到回合结束时自己只能特殊召唤「圣骑士」怪兽的限制
function c57690191.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		if ft>2 then ft=2 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 向玩家发送选择特殊召唤怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡选择1到ft张（最多2张）满足条件的「圣骑士」怪兽
		local g=Duel.SelectMatchingCard(tp,c57690191.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
		if g:GetCount()~=0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「圣骑士」怪兽不能特殊召唤。/③：1回合1次，以自己墓地的「圣骑士」卡以及「圣剑」卡合计3张为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c57690191.splimit)
	-- 注册该限制效果给玩家，使其在当前回合生效
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：不能特殊召唤「圣骑士」以外的怪兽
function c57690191.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x107a)
end
-- 过滤条件：墓地中可以返回卡组的「圣骑士」卡或「圣剑」卡
function c57690191.drfilter(c)
	return c:IsSetCard(0x107a,0x207a) and c:IsAbleToDeck()
end
-- 效果③的发动准备：检查是否能抽卡、墓地是否有3张目标卡，并选择3张目标卡作为效果对象，设置返回卡组和抽卡的操作信息
function c57690191.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57690191.drfilter(chkc) end
	-- 在效果发动阶段，检查自己是否可以抽卡，以及自己墓地是否存在至少3张满足条件的「圣骑士」或「圣剑」卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c57690191.drfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家发送选择返回卡组卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己墓地合计3张「圣骑士」或「圣剑」卡作为效果对象
	local g=Duel.SelectTarget(tp,c57690191.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置返回卡组的操作信息，指定对象卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置抽卡的操作信息，指定抽卡数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的效果处理：获取作为对象的3张卡，若全部存在则送回卡组洗切，若成功送回3张则抽1张卡
function c57690191.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将作为对象的卡片送回持有者卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果被操作的卡片中存在回到了主卡组的卡，则洗切自己的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使后续的抽卡处理与返回卡组不视为同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
