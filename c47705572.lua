--月光狼
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「月光」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：1回合1次，自己主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只「月光」融合怪兽融合召唤。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，自己的「月光」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c47705572.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（灵摆召唤、灵摆卡的发动），并注册灵摆怪兽相关的基础效果。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「月光」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c47705572.splimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己的场上·墓地的怪兽作为融合素材除外，把1只「月光」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c47705572.sptg)
	e2:SetOperation(c47705572.spop)
	c:RegisterEffect(e2)
	-- 【怪兽效果】①：只要这张卡在怪兽区域存在，自己的「月光」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c47705572.ptg)
	c:RegisterEffect(e3)
end
-- 灵摆召唤限制的判定函数：若进行灵摆召唤且召唤的怪兽不是「月光」怪兽则禁止该召唤；该限制不会被无效化。
function c47705572.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not (c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER)) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 场上融合素材候选过滤：检查怪兽是否在场上存在且可以被除外（用于发动前判断能否用场上怪兽作为融合素材）。
function c47705572.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 效果处理时场上素材过滤：检查怪兽在场上、不免疫当前效果且可以被除外，避免选中不受此效果影响的卡作为融合素材。
function c47705572.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e) and c:IsAbleToRemove()
end
-- 融合怪兽候选过滤：筛选额外牌组中满足「月光」字段、可被当前效果融合召唤、并能与现有素材组成合法融合素材组合的融合怪兽。
function c47705572.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xdf) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 墓地融合素材候选过滤：筛选自己墓地中可作为融合素材且能被除外的怪兽。
function c47705572.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 发动条件检测：收集场上·墓地的可除外素材，检查额外牌组是否存在可融合召唤的月光融合怪兽；若无则检查连锁素材是否能提供素材。满足条件则设置操作信息。
function c47705572.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组，并过滤出场上存在且可被除外的怪兽作为候选素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(c47705572.filter0,nil)
		-- 从自己墓地中筛选出可作为融合素材且能被除外的怪兽，加入候选素材。
		local mg2=Duel.GetMatchingGroup(c47705572.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外牌组是否存在至少1只月光融合怪兽，能够使用当前候选素材（场上+墓地）进行融合召唤。若存在则发动条件成立。
		local res=Duel.IsExistingMatchingCard(c47705572.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材效果（如某些卡片提供的额外融合素材），用于在通常素材不足时扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg3再次检查额外牌组中是否存在可融合召唤的月光融合怪兽。
				res=Duel.IsExistingMatchingCard(c47705572.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：声明本次效果将进行1只从额外牌组的特殊召唤（融合召唤），供其他卡连锁时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：声明本次效果将除外来自场上或墓地的卡作为融合素材，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理：从可选融合怪兽中选出1只月光融合怪兽；若使用通常素材，选择场上/墓地可除外的素材并除外，然后融合召唤；若使用连锁素材，则调用连锁素材操作进行融合召唤。
function c47705572.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理时获取普通融合素材组，过滤出场上存在、不免疫当前效果且可被除外的怪兽，避免选择不受影响的对象。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c47705572.filter1,nil,e)
	-- 效果处理时从自己墓地中筛选可作为融合素材且能被除外的怪兽。
	local mg2=Duel.GetMatchingGroup(c47705572.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 根据当前素材组（场上+墓地）筛选额外牌组中所有可融合召唤的月光融合怪兽，作为可选特殊召唤对象。
	local sg1=Duel.GetMatchingGroup(c47705572.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果，判断是否存在可用的额外融合素材来源。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 基于连锁素材提供的素材组mg3，筛选额外牌组中可融合召唤的月光融合怪兽，得到另一组可选对象。
		sg2=Duel.GetMatchingGroup(c47705572.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示，要求玩家从可选融合怪兽中选择1只要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否既能用通常素材融合，又未被强制要求使用连锁素材；若通常素材可用且玩家不选择连锁素材，则进入通常融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家为所选融合怪兽从通常素材组中选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以表侧表示除外，作为融合召唤所需的素材。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤视为不同时处理，避免错过融合召唤成功时点或产生错误连锁。
			Duel.BreakEffect()
			-- 将所选融合怪兽以融合召唤方式特殊召唤到自己的主要怪兽区域。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材组中选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 贯穿伤害目标判定：自己的「月光」怪兽攻击守备表示怪兽时，若该怪兽为「月光」怪兽卡，则给予贯穿伤害。
function c47705572.ptg(e,c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER)
end
