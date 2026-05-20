--空牙団の舵手 ヘルマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把「空牙团的舵手 赫耳玛」以外的1只「空牙团」怪兽特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，从手卡丢弃1张「空牙团」卡才能发动。自己从卡组抽1张。
function c67466547.initial_effect(c)
	-- ①：自己主要阶段才能发动。从手卡把「空牙团的舵手 赫耳玛」以外的1只「空牙团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67466547,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,67466547)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c67466547.sptg)
	e1:SetOperation(c67466547.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合，从手卡丢弃1张「空牙团」卡才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67466547,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,67466548)
	e2:SetCondition(c67466547.drcon)
	e2:SetCost(c67466547.drcost)
	e2:SetTarget(c67466547.drtg)
	e2:SetOperation(c67466547.drop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除「空牙团的舵手 赫耳玛」以外的「空牙团」怪兽
function c67466547.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and not c:IsCode(67466547) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测函数
function c67466547.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在可以特殊召唤的、除「空牙团的舵手 赫耳玛」以外的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(c67466547.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理函数
function c67466547.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「空牙团」怪兽
	local g=Duel.SelectMatchingCard(tp,c67466547.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「空牙团」怪兽
function c67466547.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsControler(tp)
end
-- 效果②的发动条件：自己场上有这张卡以外的「空牙团」怪兽特殊召唤的场合
function c67466547.drcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c67466547.cfilter,1,nil,tp)
end
-- 过滤手卡中可丢弃的「空牙团」卡（或适用特定代破/代cost效果时墓地的卡）
function c67466547.drcfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x114) and c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x114) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(53557529,tp)
	end
end
-- 效果②的发动代价（Cost）处理函数
function c67466547.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡（或特定情况下的墓地）中是否存在可作为Cost的「空牙团」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67466547.drcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1张要丢弃的「空牙团」卡
	local g=Duel.SelectMatchingCard(tp,c67466547.drcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(53557529,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的卡除外（作为代替送墓的Cost处理）
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将选中的卡作为Cost丢弃送去墓地
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 效果②的发动准备与合法性检测函数
function c67466547.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为1张
	Duel.SetTargetParam(1)
	-- 设置连锁信息，表示该效果包含玩家抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理函数
function c67466547.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡效果的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
