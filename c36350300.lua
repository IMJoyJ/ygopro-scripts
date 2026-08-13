--高尚儀式術
-- 效果：
-- 仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把手卡的通常怪兽解放，从卡组把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在对方结束阶段回到持有者卡组。
function c36350300.initial_effect(c)
	-- 仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。①：等级合计直到变成和仪式召唤的怪兽相同为止，把手卡的通常怪兽解放，从卡组把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在对方结束阶段回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36350300+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c36350300.target)
	e1:SetOperation(c36350300.activate)
	c:RegisterEffect(e1)
end
-- 定义仪式素材过滤条件：只保留通常怪兽且不在主要怪兽区的卡（即满足“把手卡的通常怪兽解放”这一要求的手卡通常怪兽）。
function c36350300.matfilter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsLocation(LOCATION_MZONE)
end
-- 发动条件判定与操作信息设置：在发动时检查是否能用可用的手卡通常怪兽作为素材，从卡组仪式召唤出等级与之合计相等的仪式怪兽；若能，则设置效果处理时将进行卡组特殊召唤。
function c36350300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家可用的仪式召唤素材（包括手卡、场上可解放的怪兽等），再用素材过滤器筛选出其中“手卡的通常怪兽”作为候选解放物。
		local mg=Duel.GetRitualMaterial(tp):Filter(c36350300.matfilter,nil)
		-- 检查卡组中是否存在至少1只仪式怪兽，它能够以候选素材mg为祭品、素材等级合计恰好等于其等级的方式被仪式召唤（决定效果是否可以发动）。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,nil,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	-- 登记本次连锁的处理信息：效果处理时将对卡组中的1只怪兽进行特殊召唤（对象未定，数量为1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段执行仪式召唤：选择1只卡组仪式怪兽，从手卡解放等级合计等于其等级的通常怪兽，进行仪式召唤；成功后为那只怪兽设置回卡组的标记和效果，并完成特殊召唤流程。
function c36350300.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 同前：获取并过滤仪式素材，得到可作为解放祭品的手卡通常怪兽集合。
	local mg=Duel.GetRitualMaterial(tp):Filter(c36350300.matfilter,nil)
	-- 弹出选择提示，要求选择要特殊召唤的卡（即卡组中的仪式怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选取1只满足条件的仪式怪兽（能够以候选素材为祭品、等级合计等于其等级进行仪式召唤）。
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,nil,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 弹出选择提示，要求选择要解放的卡（即解放手卡中的通常怪兽作为仪式祭品）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的素材组合合理性检查：确保所选素材的等级合计必须恰好等于仪式怪兽等级，避免选择多余素材。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 让玩家从候选素材中选出1组等级合计等于仪式怪兽等级的通常怪兽作为解放素材，该组通过合法性检查（包括怪兽区空位等）；若无法选出则返回nil。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除自定义的额外检查闭包，防止影响后续其他效果的素材选择。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 释放仪式素材：将选中的素材解放（如果是墓地中的仪式魔人等特殊素材则除外），完成仪式召唤的解放过程。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果的处理，使接下来的特殊召唤在时点上与前一段分离，造成错时点，以满足某些卡的发动时点要求。
		Duel.BreakEffect()
		-- 执行仪式特殊召唤的单个步骤：将选择的仪式怪兽以表侧表示仪式召唤到己方场上；若成功，则继续为其登记回卡组的后续效果。
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			local fid=e:GetHandler():GetFieldID()
			tc:RegisterFlagEffect(36350300,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这个效果特殊召唤的怪兽在对方结束阶段回到持有者卡组。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c36350300.tdcon)
			e1:SetOperation(c36350300.tdop)
			-- 将“对方结束阶段回卡组”的持续效果注册到场上，使其在该怪兽在场上期间持续监视结束阶段。
			Duel.RegisterEffect(e1,tp)
			tc:CompleteProcedure()
		end
		-- 完成整个特殊召唤流程，触发召唤成功时的各种时点和诱发效果。
		Duel.SpecialSummonComplete()
	end
end
-- 回卡组效果的发动条件：必须是对方回合的结束阶段，且被特殊召唤的怪兽仍持有对应的回卡组标记（即仍是由本效果特殊召唤的怪兽）。
function c36350300.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方的回合（即非发动者回合），否则不满足回卡组条件。
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(36350300)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 回卡组效果的实际操作：将标记对应的仪式怪兽送回持有者卡组。
function c36350300.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将该怪兽洗回持有者卡组（弹回卡组并洗牌）。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
