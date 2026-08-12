--マルチ・ピース・ゴーレム
-- 效果：
-- 「大块石人」＋「中块石人」
-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到额外卡组。并且，若回到额外卡组的这张卡的融合召唤使用过的1组融合素材怪兽在自己墓地齐集，可以再把这1组在自己场上特殊召唤。
function c71628381.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「大块石人」＋「中块石人」为素材的融合召唤手续
	aux.AddFusionProcCode2(c,25247218,58843503,true,true)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到额外卡组。并且，若回到额外卡组的这张卡的融合召唤使用过的1组融合素材怪兽在自己墓地齐集，可以再把这1组在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71628381,0))  --"返回额外卡组"
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c71628381.spcon)
	e1:SetTarget(c71628381.sptg)
	e1:SetOperation(c71628381.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在本次战斗阶段进行过战斗
function c71628381.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果发动时的对象选择与效果分类设置：确认自身能回到额外卡组，并设置回到额外卡组的操作信息
function c71628381.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置当前连锁的操作信息为：将自身送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 过滤条件：属于自身融合素材、存在于自己墓地、因融合召唤被送去墓地、且可以特殊召唤的怪兽
function c71628381.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE,true)
end
-- 效果处理：将自身送回额外卡组，若满足条件且玩家选择发动，则将墓地的融合素材怪兽特殊召唤
function c71628381.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetMaterial()
	local ct=mg:GetCount()
	-- 判断自身是否成功送回额外卡组
	if Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		and c:IsSummonType(SUMMON_TYPE_FUSION)
		-- 判断融合素材数量是否大于0，且自己场上的空怪兽区域数量是否足够容纳这组融合素材
		and ct>0 and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断融合素材是否全部存在于墓地，且不受「王家之谷」影响并满足特殊召唤条件
		and mg:FilterCount(aux.NecroValleyFilter(c71628381.mgfilter),nil,e,tp,c,mg)==ct
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and (not Duel.IsPlayerAffectedByEffect(tp,59822133) or ct==1)
		-- 询问玩家是否选择将这1组融合素材特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(71628381,1)) then  --"是否要特殊召唤融合素材？"
		-- 中断当前效果处理，使后续的特殊召唤处理与回到额外卡组不视为同时进行
		Duel.BreakEffect()
		-- 将这1组融合素材怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
