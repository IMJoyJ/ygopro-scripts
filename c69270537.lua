--コンタクト・アウト
-- 效果：
-- 自己场上表侧表示存在的1只名字带有「新宇」的融合怪兽回到融合卡组。若回到融合卡组的怪兽记述的一组融合素材怪兽在自己卡组齐集，可以再把这一组在自己场上特殊召唤。
function c69270537.initial_effect(c)
	-- 自己场上表侧表示存在的1只名字带有「新宇」的融合怪兽回到融合卡组。若回到融合卡组的怪兽记述的一组融合素材怪兽在自己卡组齐集，可以再把这一组在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c69270537.target)
	e1:SetOperation(c69270537.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、名字带有「新宇」且可以回到额外卡组的融合怪兽
function c69270537.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9) and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
-- 效果发动时的目标选择与处理，确认并选择1只满足条件的「新宇」融合怪兽作为对象
function c69270537.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c69270537.tdfilter(chkc) end
	-- 判定自己场上是否存在至少1只满足条件的「新宇」融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c69270537.tdfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择1只满足条件的「新宇」融合怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c69270537.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息，表示此效果包含将1张卡送回卡组的处理
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤卡组中记述在融合怪兽素材列表中、且可以特殊召唤的怪兽
function c69270537.spfilter(c,e,tp,fc)
	-- 判定卡片是否在融合怪兽的素材列表中，且当前状态可以被特殊召唤
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 辅助检查函数，用于在选择素材时判定怪兽区域空位是否足够，并处理「青眼精灵龙」等限制同时特殊召唤多只怪兽的效果
function c69270537.fcheck(sp)
	return function(tp,g,c)
		local ct=g:GetCount()
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetMZoneCount(sp)>=ct and not (ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133))
	end
end
-- 效果处理函数，处理融合怪兽回到额外卡组以及后续从卡组特殊召唤融合素材的操作
function c69270537.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的融合怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍适用效果且表侧表示存在，并将其送回额外卡组（洗卡组）
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_EXTRA) then
		-- 注册额外的融合素材检查函数，用于后续特殊召唤素材时的数量与场地限制判定
		aux.FCheckAdditional=c69270537.fcheck(tp)
		-- 获取卡组中所有满足特殊召唤条件且属于该融合怪兽素材的卡片组
		local sg=Duel.GetMatchingGroup(c69270537.spfilter,tp,LOCATION_DECK,0,nil,e,tp,tc)
		-- 检查卡组中是否齐集该融合怪兽的一组融合素材，并询问玩家是否选择特殊召唤
		if tc:CheckFusionMaterial(sg,nil,PLAYER_NONE,true) and Duel.SelectYesNo(tp,aux.Stringid(69270537,0)) then  --"是否要特殊召唤一组融合素材？"
			-- 中断当前效果处理，使后续的特殊召唤处理与回到额外卡组不视为同时进行
			Duel.BreakEffect()
			-- 让玩家从卡组的候选卡片中选择一组该融合怪兽的融合素材
			local mats=Duel.SelectFusionMaterial(tp,tc,sg)
			-- 将选定的一组融合素材怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(mats,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 重置额外的融合素材检查函数，避免影响后续其他效果的处理
		aux.FCheckAdditional=nil
	end
end
