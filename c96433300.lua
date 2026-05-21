--溟界の虚
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把自己场上1只爬虫类族效果怪兽解放，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段送去墓地。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合发动。爬虫类族怪兽以外的自己场上的表侧表示怪兽全部送去墓地。
function c96433300.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段，把自己场上1只爬虫类族效果怪兽解放，以对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96433300,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,96433300)
	e2:SetCondition(c96433300.spcon)
	e2:SetCost(c96433300.spcost)
	e2:SetTarget(c96433300.sptg)
	e2:SetOperation(c96433300.spop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的场合发动。爬虫类族怪兽以外的自己场上的表侧表示怪兽全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96433300,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c96433300.tgcon)
	e3:SetTarget(c96433300.tgtg)
	e3:SetOperation(c96433300.tgop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件：自己或对方的主要阶段
function c96433300.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 解放怪兽的过滤条件：自己场上的表侧表示爬虫类族效果怪兽，且解放后有可用的怪兽区域
function c96433300.rfilter(c,tp)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_EFFECT)
		-- 过滤条件：属于自己控制或表侧表示，且该怪兽解放后自己场上有可用的怪兽区域
		and (c:IsControler(tp) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
-- ①号效果的发动代价（Cost）：解放自己场上1只爬虫类族效果怪兽
function c96433300.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检测：检查场上是否存在至少1只满足解放条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c96433300.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c96433300.rfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动Cost
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤目标的过滤条件：可以被特殊召唤的怪兽
function c96433300.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动目标（Target）：以对方墓地1只怪兽为对象
function c96433300.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c96433300.spfilter(chkc,e,tp) end
	-- Target检测：检查对方墓地是否存在至少1只可以特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c96433300.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96433300.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的效果处理（Operation）：将对象怪兽特殊召唤，并注册结束阶段送去墓地的效果
function c96433300.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在且特殊召唤成功
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(96433300,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c96433300.tgcon1)
		e1:SetOperation(c96433300.tgop1)
		-- 注册在结束阶段将该怪兽送去墓地的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：该怪兽仍带有对应的标记（未离场或未失效）
function c96433300.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(96433300)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 延迟效果的处理：将该怪兽送去墓地
function c96433300.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将特殊召唤的怪兽送去墓地
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
-- ②号效果的发动条件：魔法与陷阱区域表侧表示的这张卡被送去墓地
function c96433300.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousSequence()<5
end
-- 送去墓地怪兽的过滤条件：爬虫类族以外的自己场上的表侧表示怪兽，且能送去墓地
function c96433300.cfilter(c)
	return not c:IsRace(RACE_REPTILE) and c:IsFaceup() and c:IsAbleToGrave()
end
-- ②号效果的发动准备：获取满足条件的怪兽并设置送去墓地的操作信息
function c96433300.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有爬虫类族以外的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c96433300.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- ②号效果的效果处理：将爬虫类族以外的自己场上的表侧表示怪兽全部送去墓地
function c96433300.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取自己场上所有爬虫类族以外的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c96433300.cfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		-- 将这些怪兽全部送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
