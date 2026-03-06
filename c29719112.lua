--サイバー・ファロス
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以把自己场上1只机械族怪兽解放从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。从自己的手卡·场上把机械族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ③：自己的融合怪兽被战斗破坏时，把墓地的这张卡除外才能发动。从卡组把1张「力量结合」加入手卡。
function c29719112.initial_effect(c)
	-- ①：这张卡可以把自己场上1只机械族怪兽解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c29719112.hspcon)
	e1:SetTarget(c29719112.hsptg)
	e1:SetOperation(c29719112.hspop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。从自己的手卡·场上把机械族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29719112,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c29719112.sptg)
	e2:SetOperation(c29719112.spop)
	c:RegisterEffect(e2)
	-- ③：自己的融合怪兽被战斗破坏时，把墓地的这张卡除外才能发动。从卡组把1张「力量结合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29719112,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,29719112)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c29719112.thcon)
	e3:SetTarget(c29719112.thtg)
	e3:SetOperation(c29719112.thop)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件的过滤函数，检查是否为机械族且在场上的怪兽
function c29719112.spfilter(c,tp)
	return c:IsRace(RACE_MACHINE)
		-- 判断是否满足特殊召唤条件的过滤函数，检查是否满足场上怪兽区有空位且为己方控制或表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否满足特殊召唤条件的函数，检查是否有满足条件的机械族怪兽可解放
function c29719112.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否有满足条件的机械族怪兽可解放
	return Duel.CheckReleaseGroupEx(tp,c29719112.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择要解放的怪兽的函数，从满足条件的怪兽中选择一张
function c29719112.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c29719112.spfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的怪兽解放
function c29719112.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断是否免疫效果的过滤函数
function c29719112.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 判断是否满足融合召唤条件的过滤函数，检查是否为融合怪兽且种族为机械族
function c29719112.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断是否满足融合召唤条件的函数，检查是否有满足条件的融合怪兽可特殊召唤
function c29719112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否有满足条件的融合怪兽可特殊召唤
		local res=Duel.IsExistingMatchingCard(c29719112.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否有满足条件的融合怪兽可特殊召唤
				res=Duel.IsExistingMatchingCard(c29719112.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤操作，选择融合怪兽并进行融合召唤
function c29719112.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前玩家可用的融合素材组并过滤掉免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29719112.spfilter1,nil,e)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c29719112.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c29719112.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 判断是否为融合怪兽且为己方控制的过滤函数
function c29719112.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp)
end
-- 判断是否满足效果发动条件的函数，检查是否有融合怪兽被战斗破坏
function c29719112.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29719112.cfilter,1,nil,tp)
end
-- 判断是否为「力量结合」的过滤函数
function c29719112.thfilter(c)
	return c:IsCode(37630732) and c:IsAbleToHand()
end
-- 判断是否满足检索条件的函数，检查是否有「力量结合」可加入手牌
function c29719112.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有「力量结合」可加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c29719112.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作，选择「力量结合」加入手牌
function c29719112.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,c29719112.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
