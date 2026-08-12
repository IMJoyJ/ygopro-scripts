--ヴァイロン・ポリトープ
-- 效果：
-- 选择当作装备卡使用在自己场上存在的名字带有「大日」的怪兽卡任意数量发动。选择的卡表侧守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
function c65659181.initial_effect(c)
	-- 选择当作装备卡使用在自己场上存在的名字带有「大日」的怪兽卡任意数量发动。选择的卡表侧守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c65659181.sptg)
	e1:SetOperation(c65659181.spop)
	c:RegisterEffect(e1)
end
-- 过滤在自己场上表侧表示存在、名字带有「大日」且可以表侧守备表示特殊召唤的怪兽卡
function c65659181.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x30) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的Target函数，进行发动条件检测、选择对象并设置特殊召唤的操作信息
function c65659181.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c65659181.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔陷区是否存在至少1张满足条件的「大日」怪兽卡
		and Duel.IsExistingTarget(c65659181.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择任意数量（不超过可用怪兽区域数量）的满足条件的「大日」怪兽卡作为效果的对象
	local g=Duel.SelectTarget(tp,c65659181.filter,tp,LOCATION_SZONE,0,1,ft,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含特殊召唤的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 过滤仍与效果相关且可以表侧守备表示特殊召唤的对象卡
function c65659181.spfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理的Operation函数，将选择的对象特殊召唤，并添加离场时除外的效果
function c65659181.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取本次效果发动的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c65659181.spfilter,nil,e,tp)
	if sg:GetCount()<=ft then
		local tc=sg:GetFirst()
		while tc do
			-- 将目标怪兽以表侧守备表示特殊召唤（单步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1,true)
			tc=sg:GetNext()
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	else
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local fg=sg:Select(tp,ft,ft,nil)
		local tc=fg:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧守备表示特殊召唤（单步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			tc:RegisterEffect(e1,true)
			tc=fg:GetNext()
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		sg:Sub(fg)
		-- 将因格子不足而未能特殊召唤的其余对象卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
