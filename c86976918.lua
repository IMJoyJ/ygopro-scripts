--SRマジックハウンド
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1张「疾行机人」卡送去墓地。
-- ②：把墓地的这张卡除外，以自己墓地1只「疾行机人」怪兽为对象才能发动。那只怪兽回到卡组，和那只怪兽是卡名不同并是等级相同的1只「疾行机人」同调怪兽效果无效从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c86976918.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1张「疾行机人」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86976918,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c86976918.tgtg)
	e1:SetOperation(c86976918.tgop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「疾行机人」怪兽为对象才能发动。那只怪兽回到卡组，和那只怪兽是卡名不同并是等级相同的1只「疾行机人」同调怪兽效果无效从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86976918,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86976918)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c86976918.sptg)
	e2:SetOperation(c86976918.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可以送去墓地的「疾行机人」卡
function c86976918.tgfilter(c)
	return c:IsSetCard(0x2016) and c:IsAbleToGrave()
end
-- ①效果的发动准备与检测（收集并设置操作信息）
function c86976918.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在可以送去墓地的「疾行机人」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86976918.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将1张「疾行机人」卡送去墓地
function c86976918.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c86976918.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：墓地中可以回到卡组，且额外卡组存在可特殊召唤的对应同调怪兽的「疾行机人」怪兽
function c86976918.tdfilter(c,e,tp)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
		-- 检测额外卡组是否存在与该怪兽等级相同、卡名不同且可特殊召唤的「疾行机人」同调怪兽
		and Duel.IsExistingMatchingCard(c86976918.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel(),c:GetCode())
end
-- 过滤条件：额外卡组中等级相同、卡名不同、可以特殊召唤的「疾行机人」同调怪兽
function c86976918.spfilter(c,e,tp,lv,code)
	return c:IsLevel(lv) and not c:IsCode(code) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x2016)
		-- 检测该怪兽是否可以特殊召唤，且额外怪兽区域有可用的空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备与检测（选择墓地的对象并设置操作信息）
function c86976918.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c86976918.tdfilter(chkc,e,tp) end
	-- 检测墓地中是否存在可以作为对象的「疾行机人」怪兽
	if chk==0 then return Duel.IsExistingTarget(c86976918.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地中1只满足条件的「疾行机人」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c86976918.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的对象怪兽回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：将对象怪兽回到卡组，并从额外卡组效果无效特殊召唤对应的同调怪兽
function c86976918.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其返回持有者卡组并洗牌
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		local lv,code=tc:GetLevel(),tc:GetCode()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只与返回卡组的怪兽等级相同且卡名不同的「疾行机人」同调怪兽
		local g=Duel.SelectMatchingCard(tp,c86976918.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,code)
		local sc=g:GetFirst()
		-- 若成功选出怪兽，则将其以表侧表示特殊召唤（分解步骤）
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			sc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
