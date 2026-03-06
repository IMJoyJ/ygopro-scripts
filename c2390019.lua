--おジャマ改造
-- 效果：
-- ①：把额外卡组1只机械族·光属性的融合怪兽给对方观看，把自己的手卡·场上·墓地的「扰乱」怪兽任意数量除外才能发动。从自己的手卡·卡组·墓地选除外的怪兽数量的在给人观看的怪兽有卡名记述的融合素材怪兽特殊召唤（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c2390019.initial_effect(c)
	-- 效果①：把额外卡组1只机械族·光属性的融合怪兽给对方观看，把自己的手卡·场上·墓地的「扰乱」怪兽任意数量除外才能发动。从自己的手卡·卡组·墓地选除外的怪兽数量的在给人观看的怪兽有卡名记述的融合素材怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2390019.cost)
	e1:SetTarget(c2390019.target)
	e1:SetOperation(c2390019.activate)
	c:RegisterEffect(e1)
	-- 效果②：把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2390019.drtg)
	e2:SetOperation(c2390019.drop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「扰乱」怪兽（手卡·场上·墓地）
function c2390019.cfilter(c)
	return c:IsSetCard(0xf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 过滤满足条件的融合素材怪兽（能作为fc的融合素材且能特殊召唤）
function c2390019.spfilter(c,e,tp,fc)
	-- 判断c是否为fc的融合素材且能特殊召唤
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足特殊召唤条件（怪兽数量和场地数量）
function c2390019.fselect(cg,tp,tg)
	-- 检查场地数量是否满足怪兽数量
	return Duel.GetMZoneCount(tp,cg,tp)>=#cg and tg:Filter(aux.TRUE,cg):CheckSubGroup(aux.dncheck,#cg,#cg)
end
-- 过滤满足条件的额外卡组的融合怪兽（机械族·光属性）
function c2390019.ffilter(c,e,tp,cg)
	if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)) then return false end
	-- 获取满足条件的融合素材怪兽组
	local tg=Duel.GetMatchingGroup(c2390019.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,c)
	local maxct=math.min(#tg,#cg,5)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then maxct=1 end
	return cg:CheckSubGroup(c2390019.fselect,1,maxct,tp,tg)
end
-- 设置标签为100，表示进入效果处理阶段
function c2390019.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 效果①的处理函数，选择融合怪兽并除外「扰乱」怪兽
function c2390019.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的「扰乱」怪兽组
	local cg=Duel.GetMatchingGroup(c2390019.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否存在满足条件的额外卡组融合怪兽
		return Duel.IsExistingMatchingCard(c2390019.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,cg)
	end
	-- 提示玩家选择给对方确认的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择给对方确认的融合怪兽
	local fc=Duel.SelectMatchingCard(tp,c2390019.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,cg):GetFirst()
	-- 向对方确认该融合怪兽
	Duel.ConfirmCards(1-tp,fc)
	e:SetLabelObject(fc)
	-- 获取满足条件的融合素材怪兽组
	local tg=Duel.GetMatchingGroup(c2390019.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,fc)
	local maxct=math.min(#tg,#cg,5)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then maxct=1 end
	-- 提示玩家选择要除外的「扰乱」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=cg:SelectSubGroup(tp,c2390019.fselect,false,1,maxct,tp,tg)
	-- 将选择的「扰乱」怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 获取实际除外的怪兽数量
	local ct=Duel.GetOperatedGroup():GetCount()
	e:SetLabel(ct)
	-- 设置操作信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的发动处理函数，特殊召唤融合素材怪兽
function c2390019.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then return end
	local fc=e:GetLabelObject()
	-- 获取满足条件的融合素材怪兽组（排除王家长眠之谷影响）
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c2390019.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,fc)
	if mg:GetClassCount(Card.GetCode)<ct then return end
	-- 提示玩家选择要特殊召唤的融合素材怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的融合素材怪兽
	local g=mg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选择的融合素材怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤满足条件的「扰乱」怪兽（墓地）
function c2390019.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and c:IsSetCard(0xf) and c:IsAbleToDeck()
end
-- 效果②的处理函数，选择要返回卡组的「扰乱」怪兽
function c2390019.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c2390019.tdfilter(chkc) end
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查是否存在满足条件的3只「扰乱」怪兽
		and Duel.IsExistingTarget(c2390019.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的「扰乱」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择要返回卡组的「扰乱」怪兽
	local g=Duel.SelectTarget(tp,c2390019.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息，准备返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息，准备抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的发动处理函数，返回卡组并抽卡
function c2390019.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组并筛选出与效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将目标卡送回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际操作的卡组
	local g=Duel.GetOperatedGroup()
	-- 如果送回卡组的卡中有卡组的卡，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
