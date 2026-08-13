--オルフェゴール・リリース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上2只机械族怪兽解放，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。对方场上有连接怪兽存在的场合，这个效果的对象可以变成2只。
function c47171541.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上2只机械族怪兽解放，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。对方场上有连接怪兽存在的场合，这个效果的对象可以变成2只。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,47171541+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c47171541.cost)
	e1:SetTarget(c47171541.target)
	e1:SetOperation(c47171541.activate)
	c:RegisterEffect(e1)
end
-- 筛选可解放的机械族怪兽：需为机械族，且（是tp控制，或是表侧表示），用于从可解放组中找出满足解放条件的机械族怪兽。
function c47171541.rfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 解放2只机械族怪兽作为效果发动代价。先将e的标签设为1作为已支付代价标记；获取可解放的机械族怪兽组，若存在2只可在解放后留出主怪兽区空位的怪兽，则让玩家选择并解放，同时处理代替解放次数。
function c47171541.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家tp可解放的怪兽组，并用rfilter过滤出其中的机械族怪兽，作为候选解放组。
	local rg=Duel.GetReleaseGroup(tp):Filter(c47171541.rfilter,nil,tp)
	-- 在代价检测阶段检查候选组中是否存在2只怪兽，且解放它们后主怪兽区仍有足够空位，以决定能否支付代价。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 弹出“请选择要解放的卡”的选择提示，并加载相关选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从候选组中选出2只怪兽作为解放代价，aux.mzctcheckrel保证解放后主怪兽区仍有空位。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 调用辅助函数处理代替解放次数的消耗（如暗影敌托邦等代替解放效果的次数限制）。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的2只怪兽以解放代价解放。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤对象过滤器：判断墓地怪兽能否被本效果特殊召唤，遵守召唤条件和苏生限制。
function c47171541.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义连接怪兽过滤器：用于检测对方场上是否存在表侧表示的连接怪兽，以决定是否增加可选择对象数量。
function c47171541.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 发动时选择对象：确认满足发动条件后，选择自己墓地1只（满足条件时最多2只）可特殊召唤的怪兽为对象；若青眼精灵龙效果适用或对方场上无连接怪兽，则只能选1只。
function c47171541.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算发动是否可行：若已经支付过代价或主怪兽区有空位则允许发动，否则无法选择墓地怪兽。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c47171541.spfilter(chkc,e,tp) end
	if chk==0 then
		e:SetLabel(0)
		-- 效果发动合法性检查：墓地至少有1只满足特殊召唤条件的怪兽作为对象。
		return res and Duel.IsExistingTarget(c47171541.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 确定可选择对象数量上限：不超过2只，且不能超过主怪兽区的可用空格数。
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 若对方场上不存在表侧连接怪兽（或青眼精灵龙效果适用），则对象数量上限降为1。
		or not Duel.IsExistingMatchingCard(c47171541.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		ct=1
	end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1到ct张自己墓地中可特殊召唤的怪兽，并设为效果对象。
	local g=Duel.SelectTarget(tp,c47171541.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置操作信息：登记特殊召唤的对象组及其数量，供后续连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理时：获取仍关联的对象怪兽，根据主怪兽区空格数限制实际特殊召唤数量；若青眼精灵龙效果适用且对象超过1只则中止；若对象多于空位则让玩家选择；最后特殊召唤。
function c47171541.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取主怪兽区当前可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中本效果选择的对象卡，并过滤掉已离场或不再与本效果相关的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 当对象数量超过可用的主怪兽区空格数时，提示玩家选择实际要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选中的怪兽以表侧表示特殊召唤到tp的场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
