--融合解除
-- 效果：
-- ①：以场上1只融合怪兽为对象才能发动。那只融合怪兽回到持有者的额外卡组。那之后，若回到额外卡组的那只怪兽的融合召唤使用过的一组融合素材怪兽在自己墓地齐集，可以把那一组在自己场上特殊召唤。
function c95286165.initial_effect(c)
	-- ①：以场上1只融合怪兽为对象才能发动。那只融合怪兽回到持有者的额外卡组。那之后，若回到额外卡组的那只怪兽的融合召唤使用过的一组融合素材怪兽在自己墓地齐集，可以把那一组在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95286165.target)
	e1:SetOperation(c95286165.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示、属于融合怪兽且可以回到额外卡组的卡片
function c95286165.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
-- 效果发动时的对象选择与合法性检测函数
function c95286165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c95286165.filter(chkc) end
	-- 在发动准备阶段，检测场上是否存在至少1只满足条件的融合怪兽可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c95286165.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1只满足条件的融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c95286165.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果包含将选中的卡片送回额外卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 过滤属于自己墓地、作为该融合怪兽的融合素材被送去墓地、且可以被特殊召唤的怪兽
function c95286165.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE,true)
end
-- 效果处理的核心逻辑函数，处理融合怪兽回到额外卡组以及后续特殊召唤融合素材的操作
function c95286165.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个效果对象（即目标融合怪兽）
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local mg=tc:GetMaterial()
	local ct=mg:GetCount()
	-- 将目标融合怪兽送回持有者的额外卡组，并确认其已成功回到额外卡组
	if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		and tc:IsSummonType(SUMMON_TYPE_FUSION)
		-- 确认融合素材数量大于0，且自己场上的怪兽区域空位数足够容纳这组融合素材
		and ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and (not Duel.IsPlayerAffectedByEffect(tp,59822133) or ct==1)
		-- 检测墓地中是否存在完整的一组融合素材，且这些素材不受王家长眠之谷影响并满足特殊召唤条件
		and mg:FilterCount(aux.NecroValleyFilter(c95286165.mgfilter),nil,e,tp,tc,mg)==ct
		-- 询问玩家是否选择发动特殊召唤融合素材的效果
		and Duel.SelectYesNo(tp,aux.Stringid(95286165,0)) then  --"是否要特殊召唤融合素材？"
		-- 中断当前效果处理，使后续的特殊召唤处理与回到额外卡组不视为同时进行
		Duel.BreakEffect()
		-- 将那一组融合素材怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
