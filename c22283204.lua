--ティマイオスの眼光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的场上·墓地1只「黑魔术师」或「黑魔术少女」为对象才能发动。只用那1只怪兽作为融合素材回到卡组，把有那个卡名作为融合素材记述的1只融合怪兽当作「蒂迈欧之眼」的效果作融合召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
local s,id,o=GetID()
-- 初始化效果：用aux.AddCodeList登记本卡记载的卡名，随后创建并注册这张卡作为魔法卡的“发动”效果（包含取对象、回卡组、融合召唤、除外的一体化处理）。
function s.initial_effect(c)
	-- 向系统记录本卡上记载的卡名：46986414（黑魔术师）、38033121（黑魔术少女）以及1784686（蒂迈欧之眼），用于融合素材关联判定。
	aux.AddCodeList(c,46986414,38033121,1784686)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的场上·墓地1只「黑魔术师」或「黑魔术少女」为对象才能发动。只用那1只怪兽作为融合素材回到卡组，把有那个卡名作为融合素材记述的1只融合怪兽当作「蒂迈欧之眼」的效果作融合召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
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
-- 筛选可作为对象的怪兽：必须是表侧表示（墓地存在时也算表侧）且卡名为「黑魔术师」或「黑魔术少女」，能够回到卡组、不免疫此效果、可作为融合素材，且额外卡组中存在可融合召唤的怪兽。
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(46986414,38033121) and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
		-- 追加检查该怪兽可以作为融合素材，并且没有受到“必须作为融合素材”这类效果的限制。
		and c:IsCanBeFusionMaterial() and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 确认额外卡组中存在至少1只满足s.fusfilter条件的融合怪兽，且该怪兽的融合素材记述包含所选择怪兽的卡名。
		and Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),c)
end
-- 筛选可特殊召唤的融合怪兽：必须是融合怪兽，其记述的融合素材包含所用素材的卡名，且己方额外怪兽区有可用空格，并能以融合召唤方式特殊召唤。
function s.fusfilter(c,e,tp,code,mc)
	-- 该候选融合怪兽必须属于融合怪兽种类，并且它的素材列表里含有被选为素材的怪兽的卡名。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,code)
		-- 额外卡组怪兽可以出场的区域有空位，并且该融合怪兽可以被效果以融合召唤的形式特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
-- 发动时的目标处理：检查并选择自己场上·墓地1只符合条件的「黑魔术师」或「黑魔术少女」，设定其回卡组和进行融合召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	-- 非连锁处理时确认是否存在至少1只满足筛选条件的可取对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要返回卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己场上·墓地选择1只符合条件的怪兽作为效果对象，并建立对象联系。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将所选择的怪兽返回卡组，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：本效果将进行1次从额外卡组的特殊召唤（融合召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：取得对象，验证后选择融合怪兽，将素材怪兽送回卡组，进行融合召唤，并给特殊召唤的怪兽设置下个回合结束阶段除外的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 如果对象不再是可用的融合素材，或其卡名不是「黑魔术师」或「黑魔术少女」，则效果处理不适用。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_FMATERIAL) or not tc:IsCode(46986414,38033121) then return end
	local code=tc:GetCode()
	-- 确认对象仍与当前连锁关联、不受王家长眠之谷等影响、且不免疫此效果。
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) and not tc:IsImmuneToEffect(e)
		and (tc:IsAbleToDeck() or tc:IsAbleToExtra()) then
		-- 弹出选择提示，让玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的融合怪兽作为融合召唤的对象。
		local sg=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code,tc)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(Group.FromCards(tc))
			-- 将选择的融合素材怪兽以效果原因送回卡组（洗牌后回到卡组）。
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			-- 中断当前效果处理，使后续的融合召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到己方场上，表侧表示。
			Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			local fid=sc:GetFieldID()
			sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			sc:CompleteProcedure()
			-- 这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabelObject(sc)
			-- 设定除外效果的触发回合为当前回合数+1，即下个回合。
			e1:SetLabel(Duel.GetTurnCount()+1)
			e1:SetCondition(s.rmcon(fid))
			e1:SetOperation(s.rmop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 将下个回合结束阶段除外那只怪兽的效果注册到场上。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 除外效果的触发条件：若该怪兽仍持有本次召唤时记录的标记，且当前回合同等于预设的下个回合，则执行除外；否则重置该效果。
function s.rmcon(fid)
	return function(e,tp,eg,ep,ev,re,r,rp)
			local tc=e:GetLabelObject()
			if tc:GetFlagEffect(id)~=0 and tc:GetFlagEffectLabel(id)==fid then
				-- 判断当前回合数是否已经到达预设的下个回合结束阶段。
				return Duel.GetTurnCount()==e:GetLabel()
			else
				e:Reset()
				return false
			end
	end
end
-- 除外效果的操作：展示本卡动画，若那只怪兽仍在自己场上则将其除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示本卡的卡片动画，作为除外处理时的手动提示。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		-- 将效果特殊召唤的那只怪兽以表侧表示方式除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
