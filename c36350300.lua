--高尚儀式術
-- 效果：
-- 仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把手卡的通常怪兽解放，从卡组把1只仪式怪兽仪式召唤。这个效果特殊召唤的怪兽在对方结束阶段回到持有者卡组。
function c36350300.initial_effect(c)
	-- 创建效果，设置为发动时点，可以自由连锁，限制每回合只能发动1次，目标函数为c36350300.target，发动函数为c36350300.activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36350300+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c36350300.target)
	e1:SetOperation(c36350300.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌或场上的通常怪兽作为仪式召唤的素材
function c36350300.matfilter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsLocation(LOCATION_MZONE)
end
-- 效果目标函数，检查是否存在满足条件的仪式怪兽，若存在则设置操作信息为特殊召唤
function c36350300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家可用的仪式召唤素材组，并过滤出通常怪兽
		local mg=Duel.GetRitualMaterial(tp):Filter(c36350300.matfilter,nil)
		-- 检查是否存在满足仪式召唤条件的仪式怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,nil,e,tp,mg,nil,Card.GetLevel,"Equal")
	end
	-- 设置操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动函数，处理仪式召唤的具体流程
function c36350300.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取当前玩家可用的仪式召唤素材组，并过滤出通常怪兽
	local mg=Duel.GetRitualMaterial(tp):Filter(c36350300.matfilter,nil)
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足仪式召唤条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,nil,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的等级检查函数，用于验证素材等级合计
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 从可用素材中选择满足等级要求的子集作为仪式召唤的素材
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除额外的等级检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式召唤素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 尝试特殊召唤选定的仪式怪兽
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			local fid=e:GetHandler():GetFieldID()
			tc:RegisterFlagEffect(36350300,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 注册一个在对方结束阶段触发的效果，用于将特殊召唤的怪兽送回卡组
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tc)
			e1:SetCondition(c36350300.tdcon)
			e1:SetOperation(c36350300.tdop)
			-- 将效果e1注册给玩家tp
			Duel.RegisterEffect(e1,tp)
			tc:CompleteProcedure()
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断是否为对方的结束阶段且满足条件，若满足则将怪兽送回卡组
function c36350300.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(36350300)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将怪兽送回卡组的处理函数
function c36350300.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽送回卡组，洗入卡组
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
