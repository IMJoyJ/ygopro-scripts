--ティンクル・ファイブスター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有5星怪兽1只的场合，把那只怪兽解放才能发动。从自己的手卡·卡组·墓地选「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」各1只特殊召唤。这个效果特殊召唤的怪兽不能为上级召唤而解放。
function c6309986.initial_effect(c)
	-- 注册卡片效果中提到的相关卡片密码列表（栗子丸、栗子团、栗子圆、栗子珠、栗子球）。
	aux.AddCodeList(c,44632120,71036835,7021574,34419588,40640057)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽只有5星怪兽1只的场合，把那只怪兽解放才能发动。从自己的手卡·卡组·墓地选「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」各1只特殊召唤。这个效果特殊召唤的怪兽不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,6309986+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c6309986.cost)
	e1:SetTarget(c6309986.target)
	e1:SetOperation(c6309986.activate)
	c:RegisterEffect(e1)
end
-- 创建用于检查特殊召唤的5只怪兽是否分别为「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」的条件检查函数数组。
c6309986.spchecks=aux.CreateChecks(Card.IsCode,{44632120,71036835,7021574,34419588,40640057})
-- 定义过滤自己场上可以解放且解放后能腾出5个以上怪兽区域空位的5星怪兽的过滤函数。
function c6309986.cfilter(c,tp)
	-- 检查怪兽是否表侧表示、等级为5、可以被解放，且该怪兽解放后自己场上的可用怪兽区域是否至少有5个。
	return c:IsFaceup() and c:IsLevel(5) and c:IsReleasable() and Duel.GetMZoneCount(tp,c)>=5
end
-- 效果发动的代价（Cost）处理函数，用于检查并执行解放自己场上唯一一只5星怪兽的操作。
function c6309986.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查时，如果自己场上的怪兽数量不等于1，则不能发动。
	if chk==0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=1 then return false end
	-- 获取自己场上唯一满足条件的5星怪兽。
	local rc=Duel.GetFirstMatchingCard(c6309986.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return rc end
	-- 解放该怪兽作为发动的代价。
	Duel.Release(rc,REASON_COST)
end
-- 定义过滤手卡、卡组、墓地中属于「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」且可以特殊召唤的怪兽的过滤函数。
function c6309986.spfilter(c,e,tp)
	return c:IsCode(44632120,71036835,7021574,34419588,40640057) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测（Target）处理函数。
function c6309986.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤5只怪兽所需的怪兽区域空位（若已支付代价解放了怪兽则为true，否则检查当前空位是否不少于5个）。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>=5
	if chk==0 then
		e:SetLabel(0)
		-- 获取手卡、卡组、墓地中所有满足特殊召唤条件的「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」怪兽。
		local g=Duel.GetMatchingGroup(c6309986.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return res and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:CheckSubGroupEach(c6309986.spchecks)
	end
	-- 设置连锁信息，表明此效果的处理包含从手卡、卡组、墓地特殊召唤5只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理（Operation）函数，执行特殊召唤5只怪兽并施加“不能为上级召唤而解放”限制的操作。
function c6309986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=5 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 获取手卡、卡组、墓地中满足条件且不受「王家之谷」影响的「栗子丸」「栗子团」「栗子圆」「栗子珠」「栗子球」怪兽。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c6309986.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroupEach(tp,c6309986.spchecks,false)
		if sg then
			-- 将选定的5只怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			-- 遍历特殊召唤成功的怪兽组。
			for tc in aux.Next(sg) do
				-- 这个效果特殊召唤的怪兽不能为上级召唤而解放。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(1)
				tc:RegisterEffect(e1,true)
			end
		end
	end
end
