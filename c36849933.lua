--メガリス・オク
-- 效果：
-- 「巨石遗物」卡降临。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡仪式召唤成功的场合才能发动。自己从卡组抽1张。那之后，选1张手卡丢弃。
-- ②：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
function c36849933.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。自己从卡组抽1张。那之后，选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36849933,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c36849933.drcon)
	e1:SetTarget(c36849933.drtg)
	e1:SetOperation(c36849933.drop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36849933,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,36849933)
	e2:SetCondition(c36849933.rscon)
	e2:SetTarget(c36849933.rstg)
	e2:SetOperation(c36849933.rsop)
	c:RegisterEffect(e2)
end
-- 效果适用条件：此卡必须为仪式召唤成功
function c36849933.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果处理：检查玩家是否可以抽卡并设置操作信息
function c36849933.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息：丢弃手卡效果
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：执行抽卡并丢弃手牌
function c36849933.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，若抽到卡则继续处理
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择1张手牌丢弃
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的手牌送入墓地
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 效果适用条件：只能在主要阶段发动
function c36849933.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前阶段为准备阶段或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 辅助函数：用于检查是否包含特定卡片
function c36849933.rcheck(gc)
	return	function(tp,g,c)
				return g:IsContains(gc)
			end
end
-- 效果处理：检查是否可以发动仪式召唤
function c36849933.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取玩家可用的仪式召唤素材
		local mg=Duel.GetRitualMaterial(tp)
		-- 设置额外的仪式召唤检查函数
		aux.RCheckAdditional=c36849933.rcheck(c)
		-- 检查是否满足仪式召唤条件
		local res=mg:IsContains(c) and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
		-- 清除额外的仪式召唤检查函数
		aux.RCheckAdditional=nil
		return res
	end
	-- 设置操作信息：特殊召唤仪式怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：执行仪式召唤
function c36849933.rsop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local c=e:GetHandler()
	-- 获取玩家可用的仪式召唤素材
	local mg=Duel.GetRitualMaterial(tp)
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or not mg:IsContains(c) then return end
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置额外的仪式召唤检查函数
	aux.RCheckAdditional=c36849933.rcheck(c)
	-- 选择1只仪式怪兽进行特殊召唤
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
		mg:RemoveCard(tc)
		end
		if not mg:IsContains(c) then return end
		-- 提示玩家选择要解放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置已选择的卡片为当前处理对象
		Duel.SetSelectedCard(c)
		-- 设置额外的等级检查函数
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 选择满足条件的卡片组作为仪式召唤素材
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除额外的等级检查函数
		aux.GCheckAdditional=nil
		if not mat then
			-- 清除额外的仪式召唤检查函数
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		-- 解放仪式召唤所需素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理流程
		Duel.BreakEffect()
		-- 将选中的仪式怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	-- 清除额外的仪式召唤检查函数
	aux.RCheckAdditional=nil
end
