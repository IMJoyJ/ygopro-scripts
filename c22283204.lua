--ティマイオスの眼光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的场上·墓地1只「黑魔术师」或「黑魔术少女」为对象才能发动。只用那1只怪兽作为融合素材回到卡组，把有那个卡名作为融合素材记述的1只融合怪兽当作「蒂迈欧之眼」的效果作融合召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
local s,id,o=GetID()
-- 初始化效果，注册卡名代码列表并创建发动效果
function s.initial_effect(c)
	-- 记录该卡与「黑魔术师」、「黑魔术少女」、「蒂迈欧之眼」的关联
	aux.AddCodeList(c,46986414,38033121,1784686)
	-- ①：以自己的场上·墓地1只「黑魔术师」或「黑魔术少女」为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标是否满足作为融合素材的条件
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(46986414,38033121) and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
		-- 目标必须能成为融合素材且必须作为融合素材
		and c:IsCanBeFusionMaterial() and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查是否存在满足融合条件的融合怪兽
		and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),c)
end
-- 融合怪兽过滤函数，判断是否能作为融合召唤的素材
function s.fusfilter(c,e,tp,code,mc)
	-- 融合怪兽必须包含指定卡号作为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,code)
		-- 融合怪兽必须满足召唤条件且场上存在召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
-- 处理效果目标选择，设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	-- 检查是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将目标卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果的处理函数，执行融合召唤和除外效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 验证目标卡是否满足融合素材要求且为指定卡名
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_FMATERIAL) or not tc:IsCode(46986414,38033121) then return end
	local code=tc:GetCode()
	-- 验证目标卡是否在连锁中且未被免疫
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) and not tc:IsImmuneToEffect(e)
		and (tc:IsAbleToDeck() or tc:IsAbleToExtra()) then
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足融合条件的融合怪兽
		local sg=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code,tc)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(Group.FromCards(tc))
			-- 将目标卡返回卡组
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			local fid=sc:GetFieldID()
			sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			sc:CompleteProcedure()
			-- ①：这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabelObject(sc)
			-- 设置效果标签为下个回合的结束阶段
			e1:SetLabel(Duel.GetTurnCount()+1)
			e1:SetCondition(s.rmcon(fid))
			e1:SetOperation(s.rmop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 注册效果，使融合怪兽在下个回合结束时除外
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断是否到回合结束阶段并触发除外效果
function s.rmcon(fid)
	return function(e,tp,eg,ep,ev,re,r,rp)
			local tc=e:GetLabelObject()
			if tc:GetFlagEffect(id)~=0 and tc:GetFlagEffectLabel(id)==fid then
				-- 判断是否为下个回合的结束阶段
				return Duel.GetTurnCount()==e:GetLabel()
			else
				e:Reset()
				return false
			end
	end
end
-- 除外效果的处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示除外效果发动
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		-- 将融合怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
