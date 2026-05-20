--覇王天龍の魂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只原本攻击力是2500的魔法师族灵摆怪兽解放才能发动。自己的手卡·卡组·额外卡组·场上·墓地的怪兽作为融合素材除外，把1只「霸王龙 扎克」融合召唤。除自己的除外状态的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各存在的场合外，这个效果特殊召唤的怪兽的效果无效化。
function c76840111.initial_effect(c)
	-- 记录该卡记载了「霸王龙 扎克」的卡名
	aux.AddCodeList(c,13331639)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只原本攻击力是2500的魔法师族灵摆怪兽解放才能发动。自己的手卡·卡组·额外卡组·场上·墓地的怪兽作为融合素材除外，把1只「霸王龙 扎克」融合召唤。除自己的除外状态的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各存在的场合外，这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,76840111+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c76840111.cost)
	e1:SetTarget(c76840111.target)
	e1:SetOperation(c76840111.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：原本攻击力是2500的魔法师族灵摆怪兽
function c76840111.rfilter(c,tp)
	return c:GetBaseAttack()==2500 and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_PENDULUM)
end
-- 发动代价：解放自己场上1只原本攻击力是2500的魔法师族灵摆怪兽
function c76840111.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为解放代价的原本攻击力是2500的魔法师族灵摆怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c76840111.rfilter,1,nil,tp) end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只原本攻击力是2500的魔法师族灵摆怪兽
	local g=Duel.SelectReleaseGroup(tp,c76840111.rfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：可以被除外的卡
function c76840111.filter0(c)
	return c:IsAbleToRemove()
end
-- 过滤条件：可以被除外且不受当前效果影响的卡
function c76840111.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以被融合召唤的「霸王龙 扎克」
function c76840111.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCode(13331639) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤条件：可以作为融合素材且可以被除外的怪兽
function c76840111.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 效果发动时的目标检查与操作信息设置
function c76840111.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上可以被除外的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(c76840111.filter0,nil)
		-- 获取玩家卡组、额外卡组、墓地中可以作为融合素材且可以被除外的怪兽
		local mg2=Duel.GetMatchingGroup(c76840111.filter3,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用上述素材融合召唤的「霸王龙 扎克」
		local res=Duel.IsExistingMatchingCard(c76840111.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，是否能融合召唤「霸王龙 扎克」
				res=Duel.IsExistingMatchingCard(c76840111.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：从手卡、卡组、额外卡组、场上、墓地将卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理：进行融合召唤，并根据除外状态的特定怪兽存在情况决定是否无效化其效果
function c76840111.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取手卡和场上可以被除外且不受当前效果影响的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c76840111.filter1,nil,e)
	-- 获取卡组、额外卡组、墓地中可以作为融合素材且可以被除外的怪兽
	local mg2=Duel.GetMatchingGroup(c76840111.filter3,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取额外卡组中可以使用上述素材融合召唤的「霸王龙 扎克」集合
	local sg1=Duel.GetMatchingGroup(c76840111.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用连锁素材效果时，可以融合召唤的「霸王龙 扎克」集合
		sg2=Duel.GetMatchingGroup(c76840111.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（而非连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择一组融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与除外同时处理
			Duel.BreakEffect()
			-- 将「霸王龙 扎克」以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材提供的卡片组中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 检查自己除外状态的卡中是否存在「灵摆龙」怪兽
		local b1=Duel.IsExistingMatchingCard(c76840111.efilter1,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查自己除外状态的卡中是否存在「超量龙」怪兽
		local b2=Duel.IsExistingMatchingCard(c76840111.efilter2,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查自己除外状态的卡中是否存在「同调龙」怪兽
		local b3=Duel.IsExistingMatchingCard(c76840111.efilter3,tp,LOCATION_REMOVED,0,1,nil)
		-- 检查自己除外状态的卡中是否存在「融合龙」怪兽
		local b4=Duel.IsExistingMatchingCard(c76840111.efilter4,tp,LOCATION_REMOVED,0,1,nil)
		if not b1 or not b2 or not b3 or not b4 then
			-- 除自己的除外状态的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各存在的场合外，这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 除自己的除外状态的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各存在的场合外，这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤条件：表侧表示的「灵摆龙」怪兽
function c76840111.efilter1(c)
	return c:IsSetCard(0x10f2) and c:IsFaceup()
end
-- 过滤条件：表侧表示的「超量龙」怪兽
function c76840111.efilter2(c)
	return c:IsSetCard(0x2073) and c:IsFaceup()
end
-- 过滤条件：表侧表示的「同调龙」怪兽
function c76840111.efilter3(c)
	return c:IsSetCard(0x2017) and c:IsFaceup()
end
-- 过滤条件：表侧表示的「融合龙」怪兽
function c76840111.efilter4(c)
	return c:IsSetCard(0x1046) and c:IsFaceup()
end
