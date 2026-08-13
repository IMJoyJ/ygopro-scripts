--煉獄の虚夢
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的原本等级是2星以上的「狱火机」怪兽等级变成1星，那些怪兽给与对方的战斗伤害变成一半。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「狱火机」融合怪兽融合召唤。从额外卡组特殊召唤的怪兽只有对方场上才存在的场合，自己卡组的怪兽也能有最多6只作为融合素材。
function c31444249.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔法与陷阱区域存在，自己场上的原本等级是2星以上的「狱火机」怪兽等级变成1星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	e2:SetTarget(c31444249.lvtg)
	c:RegisterEffect(e2)
	-- 那些怪兽给与对方的战斗伤害变成一半
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c31444249.rdtg)
	-- 将EFFECT_CHANGE_BATTLE_DAMAGE的Value设置为：对玩家1（对手）造成的战斗伤害变为一半，即让适用怪兽给予对方的战斗伤害减半
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- 把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「狱火机」融合怪兽融合召唤。从额外卡组特殊召唤的怪兽只有对方场上才存在的场合，自己卡组的怪兽也能有最多6只作为融合素材。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c31444249.spcost)
	e4:SetTarget(c31444249.sptg)
	e4:SetOperation(c31444249.spop)
	c:RegisterEffect(e4)
end
-- 筛选条件：怪兽为「狱火机」且其原本等级在2星以上，作为等级变更的适用对象
function c31444249.lvtg(e,c)
	return c:IsSetCard(0xbb) and c:GetOriginalLevel()>=2
end
-- 筛选条件：怪兽为「狱火机」且其原本等级在2星以上，作为战斗伤害减半的适用对象
function c31444249.rdtg(e,c)
	return c:IsSetCard(0xbb) and c:GetOriginalLevel()>=2
end
-- ②的发动代价处理：检查这张卡是否可作为代价送去墓地；若可以则将其从魔法与陷阱区域表侧表示送去墓地
function c31444249.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以代价（REASON_COST）将这张卡从魔法与陷阱区域送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选卡组中的怪兽：是怪兽、可以作为融合素材、并且可以送去墓地（用于把卡组怪兽也作为融合素材）
function c31444249.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 筛选素材时排除不受这个效果影响的卡（对效果免疫的卡不能作为本效果的融合素材）
function c31444249.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选可作为融合召唤对象的「狱火机」融合怪兽：能用提供的素材组m进行融合召唤，且没有额外素材限制（f）时也满足
function c31444249.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xbb) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 额外素材检查：一组素材中来自卡组的卡数量不超过6张
function c31444249.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=6
end
-- 额外素材组检查：一组素材中来自卡组的卡数量不超过6张（与FCheck配套的GCheck限制）
function c31444249.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=6
end
-- 判断是否满足“从额外卡组特殊召唤的怪兽只有对方场上才存在”：自己场上没有从额外卡组特殊召唤的怪兽，且对方场上有
function c31444249.dmcon(tp)
	-- 条件前半：自己场上不存在从额外卡组特殊召唤的怪兽
	return not Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,LOCATION_MZONE,0,1,nil,LOCATION_EXTRA)
		-- 条件后半：对方场上存在从额外卡组特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
-- 发动时选择合适的融合对象：获取常规融合素材，若满足额外素材条件则把卡组中可作素材的怪兽并入素材组并设置数量限制，检查能否融合召唤「狱火机」怪兽；若无则尝试使用连锁素材；可发动时登记特殊召唤操作信息
function c31444249.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己当前可用于融合召唤的素材组（包括手卡·场上的怪兽以及受额外融合素材效果影响的卡）
		local mg1=Duel.GetFusionMaterial(tp)
		if c31444249.dmcon(tp) then
			-- 获取自己卡组中可作融合素材的怪兽组
			local sg=Duel.GetMatchingGroup(c31444249.filter0,tp,LOCATION_DECK,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置额外的融合素材选择检查函数，限制一组素材中卡组来源的卡不超过6张
				aux.FCheckAdditional=c31444249.fcheck
				-- 设置额外的素材组检查函数，同样限制卡组来源素材最多6张
				aux.GCheckAdditional=c31444249.gcheck
			end
		end
		-- 检查额外卡组中是否存在用当前素材组可以融合召唤的「狱火机」融合怪兽
		local res=Duel.IsExistingMatchingCard(c31444249.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除临时设置的可选素材检查函数，避免影响后续判定
		aux.FCheckAdditional=nil
		-- 清除临时设置的素材组检查函数，避免影响后续判定
		aux.GCheckAdditional=nil
		if not res then
			-- 获取连锁素材效果（如可用作融合素材的替代效果），用于支持连锁素材融合
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在使用连锁素材提供的素材组后，再次检查是否存在可融合召唤的「狱火机」融合怪兽
				res=Duel.IsExistingMatchingCard(c31444249.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：本次效果将从额外卡组特殊召唤1只怪兽（类型为特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：整理可用融合素材（包括卡组素材并限制最多6张），列出可选的「狱火机」融合怪兽，让玩家选择其中1只；若使用常规素材则选择素材、送墓并融合召唤，若使用连锁素材则按连锁素材效果处理
function c31444249.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材，并排除不受本效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c31444249.filter1,nil,e)
	local exmat=false
	if c31444249.dmcon(tp) then
		-- 获取自己卡组中可作融合素材的怪兽组
		local sg=Duel.GetMatchingGroup(c31444249.filter0,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置额外的素材选择检查函数，限制卡组素材数量不超过6张
		aux.FCheckAdditional=c31444249.fcheck
		-- 设置额外的素材组检查函数，限制卡组素材数量不超过6张
		aux.GCheckAdditional=c31444249.gcheck
	end
	-- 生成用常规素材组可融合召唤的「狱火机」融合怪兽列表
	local sg1=Duel.GetMatchingGroup(c31444249.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除临时设置的素材选择检查函数
	aux.FCheckAdditional=nil
	-- 清除临时设置的素材组检查函数
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 生成用连锁素材组可融合召唤的「狱火机」融合怪兽列表
		sg2=Duel.GetMatchingGroup(c31444249.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡（显示选择框）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否通过常规素材召唤：若它属于常规素材可召唤的范围，且（不属于连锁素材范围或玩家选择不使用连锁素材），则走常规融合；否则走连锁素材流程
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 在选择常规融合素材前，重新设置额外的素材检查函数，限制卡组素材最多6张
				aux.FCheckAdditional=c31444249.fcheck
				-- 重新设置额外的素材组检查函数，限制卡组素材最多6张
				aux.GCheckAdditional=c31444249.gcheck
			end
			-- 让玩家从可用素材组mg1中选择一组用于融合召唤tc的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除额外素材选择检查函数
			aux.FCheckAdditional=nil
			-- 清除额外素材组检查函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，送墓原因包含效果处理、融合素材和融合召唤
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合素材送墓与后续特殊召唤不在同一时点处理（会造成错时点）
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到tp的场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，让玩家从连锁素材组mg2中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
