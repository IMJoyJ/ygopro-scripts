--オルフェゴール・リリース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上2只机械族怪兽解放，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。对方场上有连接怪兽存在的场合，这个效果的对象可以变成2只。
function c47171541.initial_effect(c)
	-- ①：把自己场上2只机械族怪兽解放，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。对方场上有连接怪兽存在的场合，这个效果的对象可以变成2只。
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
-- 过滤函数，用于筛选满足条件的机械族怪兽（包括己方控制或正面表示的怪兽）
function c47171541.rfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动时的费用处理：选择并解放2只符合条件的机械族怪兽
function c47171541.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家可解放的机械族怪兽组
	local rg=Duel.GetReleaseGroup(tp):Filter(c47171541.rfilter,nil,tp)
	-- 检查是否能选出2只满足条件的怪兽进行解放
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从符合条件的怪兽中选择2只进行解放
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 使用代替解放次数的效果（如暗影敌托邦）
	aux.UseExtraReleaseCount(g,tp)
	-- 实际执行解放操作，消耗怪兽作为发动费用
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于筛选可特殊召唤的怪兽
function c47171541.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于筛选正面表示的连接怪兽
function c47171541.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果发动时的目标选择处理：确定最多可选择2只怪兽进行特殊召唤
function c47171541.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否满足发动条件（标签为1或场上存在空位）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c47171541.spfilter(chkc,e,tp) end
	if chk==0 then
		e:SetLabel(0)
		-- 检查墓地是否存在满足条件的怪兽作为目标
		return res and Duel.IsExistingTarget(c47171541.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 计算最多可选择的怪兽数量（不超过2且不超过场上空位数）
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 若对方场上有连接怪兽则限制只能选择1只怪兽
		or not Duel.IsExistingMatchingCard(c47171541.cfilter,tp,0,LOCATION_MZONE,1,nil) then
		ct=1
	end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c47171541.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置连锁操作信息，记录将要特殊召唤的怪兽数量和类型
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果发动时的实际处理：执行特殊召唤操作
function c47171541.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中已选定的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将目标怪兽以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
