--リチュアに伝わりし禁断の秘術
-- 效果：
-- 名字带有「遗式」的仪式怪兽的降临必需。必须从自己场上以及对方场上把直到变成和仪式召唤的怪兽相同等级为止的表侧表示存在的怪兽解放。这个效果仪式召唤的怪兽的攻击力变成一半。这张卡发动的回合，自己不能进行战斗阶段。
function c28429121.initial_effect(c)
	-- 效果作用：将此卡注册为一个可以发动的魔法卡，具有特殊召唤的分类，可以在自由连锁时发动，需要支付费用，目标为自身，发动时执行activate效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28429121.cost)
	e1:SetTarget(c28429121.target)
	e1:SetOperation(c28429121.activate)
	c:RegisterEffect(e1)
end
-- 效果原文内容：这张卡发动的回合，自己不能进行战斗阶段
function c28429121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查当前阶段是否不是主要阶段2，若是则返回true表示可以发动此卡
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 效果原文内容：这张卡发动的回合，自己不能进行战斗阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将效果e1注册给玩家tp，使其在当前回合无法进入战斗阶段
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：定义一个过滤函数，用于筛选场上表侧表示存在的、等级大于0、未被免疫效果且可以解放的怪兽
function c28429121.mfilter(c,e)
	return c:IsFaceup() and c:GetLevel()>0 and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
-- 效果作用：定义一个过滤函数，用于筛选名字带有「遗式」的怪兽
function c28429121.filter(c,e,tp)
	return c:IsSetCard(0x3a)
end
-- 效果作用：检查是否满足仪式召唤条件，即在手牌中存在满足条件的仪式怪兽
function c28429121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 效果作用：获取玩家tp可用的用于仪式召唤的素材卡片组（包括手牌、场上、墓地等）
		local mg1=Duel.GetRitualMaterial(tp)
		mg1:Remove(Card.IsLocation,nil,LOCATION_HAND)
		-- 效果作用：获取玩家tp场上所有满足条件的怪兽（表侧表示、可解放）
		local mg2=Duel.GetMatchingGroup(c28429121.mfilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 效果作用：检查是否存在满足仪式召唤条件的怪兽（名字带有「遗式」且等级符合要求）
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c28429121.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	end
	-- 效果作用：设置操作信息，表示本次效果处理将特殊召唤1张手牌中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：执行仪式召唤的处理流程，包括选择仪式怪兽、选择解放的素材、设置攻击力减半效果并特殊召唤
function c28429121.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 效果作用：获取玩家tp可用的用于仪式召唤的素材卡片组（包括手牌、场上、墓地等）
	local mg1=Duel.GetRitualMaterial(tp)
	mg1:Remove(Card.IsLocation,nil,LOCATION_HAND)
	-- 效果作用：获取玩家tp场上所有满足条件的怪兽（表侧表示、可解放）
	local mg2=Duel.GetMatchingGroup(c28429121.mfilter,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 效果作用：提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从手牌中选择满足仪式召唤条件的仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c28429121.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	local tc=tg:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 效果作用：提示玩家选择要解放的素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 效果作用：设置额外的仪式召唤检查函数，用于验证所选素材是否满足等级要求
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 效果作用：从可用素材中选择满足等级要求的子集作为解放的素材
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 效果作用：清除额外的仪式召唤检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 效果作用：将选中的素材进行解放处理
		Duel.ReleaseRitualMaterial(mat)
		-- 效果作用：中断当前效果处理，使之后的效果视为不同时处理
		Duel.BreakEffect()
		-- 效果原文内容：这个效果仪式召唤的怪兽的攻击力变成一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		-- 效果作用：将选中的仪式怪兽以仪式召唤方式特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
