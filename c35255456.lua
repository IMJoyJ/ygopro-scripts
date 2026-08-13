--ミラクル・コンタクト
-- 效果：
-- ①：从自己的手卡·场上·墓地让融合怪兽卡决定的融合素材怪兽回到持有者卡组，把以「元素英雄 新宇侠」为融合素材的那1只「元素英雄」融合怪兽无视召唤条件从额外卡组特殊召唤。
function c35255456.initial_effect(c)
	-- 将卡片密码89943723（元素英雄 新宇侠）登记为这张卡记载的卡名，用于判定融合素材要求。
	aux.AddCodeList(c,89943723)
	-- 向这张卡登记“元素英雄”系列字段（0x3008），用于识别需要特殊召唤的融合怪兽。
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己的手卡·场上·墓地让融合怪兽卡决定的融合素材怪兽回到持有者卡组，把以「元素英雄 新宇侠」为融合素材的那1只「元素英雄」融合怪兽无视召唤条件从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35255456.target)
	e1:SetOperation(c35255456.activate)
	c:RegisterEffect(e1)
end
-- 定义素材筛选条件：卡能够回到卡组，且不免疫此效果。
function c35255456.filter1(c,e)
	return c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 定义额外卡组可特殊召唤的融合怪兽的筛选条件：属于“元素英雄”融合怪兽、卡名素材中包含“元素英雄 新宇侠”、能够被特殊召唤，且用当前可用素材能构成融合素材组合。
function c35255456.filter2(c,e,tp,m,chkf)
	-- 该怪兽必须是「元素英雄」融合怪兽，并且其融合素材中记载有「元素英雄 新宇侠」。
	return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf,true)
end
-- 发动时的合法性检查：先从自己的手卡·场上·墓地收集可作为素材且能回卡组的卡组，再确认额外卡组存在满足条件的「元素英雄」融合怪兽；满足后设置“特殊召唤”的操作信息。
function c35255456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp|0x200
		-- 获取自己手卡、场上、墓地中所有满足素材条件的卡，作为可选的融合素材集合。
		local mg=Duel.GetMatchingGroup(c35255456.filter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
		-- 检查额外卡组是否存在至少1只符合条件的「元素英雄」融合怪兽。
		return Duel.IsExistingMatchingCard(c35255456.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	-- 将本次效果处理信息设定为：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义需要向对方展示的素材：位于手牌或场上里侧表示的卡。
function c35255456.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
-- 效果处理时：从手卡·场上·墓地选择融合素材送回持有者卡组（洗牌），并将符合条件的「元素英雄」融合怪兽无视召唤条件特殊召唤。
function c35255456.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|0x200
	-- 处理时重新获取手卡·场上·墓地的候选素材，并排除因“王家长眠之谷”等效果不能从墓地回卡组的卡。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c35255456.filter1),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
	-- 获取额外卡组中所有满足素材和召唤条件的「元素英雄」融合怪兽。
	local sg=Duel.GetMatchingGroup(c35255456.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if sg:GetCount()>0 then
		-- 向玩家发出“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 为选择的融合怪兽从候选素材中挑选所需的一组融合素材。
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf,true)
		local cf=mat:Filter(c35255456.cffilter,nil)
		if cf:GetCount()>0 then
			-- 将选定的素材中属于手牌或里侧表示的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,cf)
		end
		-- 将选择的融合素材返回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 将选择的「元素英雄」融合怪兽以表侧表示特殊召唤到己方场上（无视召唤条件）。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
