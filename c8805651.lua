--メガリス・フローチュ
-- 效果：
-- 「巨石遗物」卡降临
-- 这个卡名的②的效果1回合只能使用1次，①②的效果在同一连锁上不能发动。
-- ①：这张卡仪式召唤的场合才能发动。从自己墓地把1张「巨石遗物」卡加入手卡。
-- ②：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从自己墓地把「巨石遗物·富洛曲」以外的1只「巨石遗物」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含仪式召唤限制、①效果（仪式召唤成功时回收墓地卡片）和②效果（主要阶段进行仪式召唤）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤的场合才能发动。从自己墓地把1张「巨石遗物」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.srcon)
	e1:SetTarget(s.srtg)
	e1:SetOperation(s.srop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把包含场上的这张卡的自己的手卡·场上的怪兽解放，从自己墓地把「巨石遗物·富洛曲」以外的1只「巨石遗物」仪式怪兽仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rscon)
	e2:SetTarget(s.rstg)
	e2:SetOperation(s.rsop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡仪式召唤成功。
function s.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- ①效果的过滤条件：自己墓地的一张「巨石遗物」卡。
function s.srfilter(c)
	return c:IsSetCard(0x138) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检查（包含同一连锁不能发动②效果的检测）。
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以加入手牌的「巨石遗物」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查本连锁中是否尚未发动过②效果（用于实现同一连锁不能发动的限制）。
		and Duel.GetFlagEffect(tp,id+o)==0 end
	-- 在本连锁中注册①效果已发动的标记，防止在同一连锁中发动②效果。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置效果处理信息：从墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的处理：从自己墓地选择1张「巨石遗物」卡加入手牌。
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从墓地选择1张满足条件的「巨石遗物」卡（受「王家之谷」影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.srfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：自己或对方的主要阶段。
function s.rscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 辅助检查函数：用于确保仪式召唤的素材中必须包含指定的卡（即场上的这张卡）。
function s.rcheck(gc)
	return  function(tp,g,c)
				return g:IsContains(gc)
			end
end
-- ②效果的仪式怪兽过滤条件：自己墓地中除「巨石遗物·富洛曲」以外的、可以进行仪式召唤的「巨石遗物」仪式怪兽。
function s.rsfilter(c,e,tp,mg)
	-- 过滤非同名且属于「巨石遗物」系列，并且在给定的素材组下满足仪式召唤条件的怪兽。
	return not c:IsCode(id) and c:IsSetCard(0x138) and aux.RitualUltimateFilter(c,aux.TRUE,e,tp,mg,nil,Card.GetLevel,"Greater")
end
-- ②效果的发动准备与合法性检查（包含同一连锁不能发动①效果的检测）。
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取玩家当前可用的仪式素材卡片组。
		local mg=Duel.GetRitualMaterial(tp)
		-- 设定附加仪式素材检查：素材中必须包含场上的这张卡。
		aux.RCheckAdditional=s.rcheck(c)
		-- 检查可用素材中是否包含这张卡，且墓地中是否存在可仪式召唤的「巨石遗物」怪兽。
		local res=mg:IsContains(c) and Duel.IsExistingMatchingCard(s.rsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mg)
		-- 重置附加仪式素材检查函数，避免影响后续的其他仪式召唤。
		aux.RCheckAdditional=nil
		-- 返回检查结果，并确保本连锁中尚未发动过①效果。
		return res and Duel.GetFlagEffect(tp,id)==0
	end
	-- 在本连锁中注册②效果已发动的标记，防止在同一连锁中发动①效果。
	Duel.RegisterFlagEffect(tp,id+o,RESET_CHAIN,0,1)
	-- 设置效果处理信息：从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：从自己墓地选择1只「巨石遗物」仪式怪兽，将包含场上这张卡的怪兽解放进行仪式召唤。
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家当前可用的仪式素材卡片组。
	local mg=Duel.GetRitualMaterial(tp)
	if c:IsControler(1-tp) or not c:IsRelateToChain() or not mg:IsContains(c) then return end
	::cancel::
	-- 提示玩家选择要特殊召唤（仪式召唤）的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设定附加仪式素材检查：素材中必须包含场上的这张卡。
	aux.RCheckAdditional=s.rcheck(c)
	-- 玩家从墓地选择1只满足仪式召唤条件的「巨石遗物」仪式怪兽（受「王家之谷」影响）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rsfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		if not mg:IsContains(c) then
			-- 重置附加仪式素材检查函数。
			aux.RCheckAdditional=nil
		end
		-- 提示玩家选择要解放的仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 强制将场上的这张卡设为已被选中的仪式素材。
		Duel.SetSelectedCard(c)
		-- 设定附加组检查：确保所选素材的等级合计达到目标怪兽的等级以上。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 玩家选择满足仪式召唤条件的素材怪兽组。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 重置附加组检查函数。
		aux.GCheckAdditional=nil
		if not mat then
			-- 重置附加仪式素材检查函数（在取消选择或异常处理时）。
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续的特殊召唤不与解放同时处理。
		Duel.BreakEffect()
		-- 将选中的仪式怪兽以仪式召唤的方式表侧表示特殊召唤。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	-- 效果处理结束，重置附加仪式素材检查函数。
	aux.RCheckAdditional=nil
end
