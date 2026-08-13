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
	-- 这个卡名的③的效果1回合只能使用1次。③：自己的融合怪兽被战斗破坏时，把墓地的这张卡除外才能发动。从卡组把1张「力量结合」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29719112,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,29719112)
	-- 设置③效果的发动代价：把墓地的这张卡除外（使用aux.bfgcost作为cost函数，支付时除外自身）。
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c29719112.thcon)
	e3:SetTarget(c29719112.thtg)
	e3:SetOperation(c29719112.thop)
	c:RegisterEffect(e3)
end
-- 过滤可作为①效果解放的机械族怪兽：要求机械族，且解放后己方仍有空余怪兽区，同时该卡为自己控制或表侧表示（满足解放要求）。
function c29719112.spfilter(c,tp)
	return c:IsRace(RACE_MACHINE)
		-- 该行检查解放素材c后是否仍有空余怪兽区可特殊召唤电子灯塔，并限定c需为自己控制或表侧表示。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断①效果的特殊召唤规则是否可用：若c为空则返回true（用于效果描述显示），否则检查tp是否有可解放的机械族素材且解放后仍有空怪兽区。
function c29719112.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp是否存在至少1只满足spfilter条件的可解放机械族怪兽（用于①效果从手卡特殊召唤时作为解放素材）。
	return Duel.CheckReleaseGroupEx(tp,c29719112.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- ①效果特殊召唤时的选择处理：从可解放的素材组中筛出符合条件的机械族，由tp选择1张作为解放素材并保存到效果标签；未选择则返回false。
function c29719112.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp场上可解放的怪兽（不包含手卡），并过滤出满足spfilter的机械族候选素材。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c29719112.spfilter,nil,tp)
	-- 显示选择提示：请选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①效果实际处理：取出之前选定的解放素材并解放，完成从手卡特殊召唤的手续。
function c29719112.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤相关原因（REASON_SPSUMMON）将选中的机械族怪兽解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数：排除对当前融合效果免疫的卡，即免疫效果的卡不能作为融合素材。
function c29719112.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 从额外卡组筛选可融合召唤的机械族融合怪兽：必须为机械族融合怪兽，当前效果允许特殊召唤，且能用素材组m（附带可能的额外限制f）满足其融合素材条件。
function c29719112.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果发动时的目标检查：先用普通融合素材检查额外卡组是否有可融合召唤的机械族融合怪兽；若无，再检查连锁素材效果是否提供额外素材；只要有候选则发动，并登记操作信息为从额外卡组特殊召唤。
function c29719112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得tp当前可用的融合素材组（包括手卡·场上的怪兽，以及额外融合素材效果允许的卡），用于判断和实际融合。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只满足spfilter2的机械族融合怪兽（能以mg1为素材进行融合召唤），作为②效果能否发动的条件之一。
		local res=Duel.IsExistingMatchingCard(c29719112.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取tp正在适用的连锁素材效果（若有），该效果可改变融合召唤的素材来源（如使用卡组/额外卡组等）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，用其返回的素材组mg2和额外限制mf，再次检查额外卡组是否存在可融合召唤的机械族融合怪兽，作为替代召唤路线。
				res=Duel.IsExistingMatchingCard(c29719112.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向连锁处理系统登记：本次效果将在额外卡组进行1次特殊召唤，以便其他卡（如星尘龙）对特殊召唤进行正确连锁。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理时的实际融合召唤：筛选出所有可召唤的机械族融合怪兽，让tp选择其一；若要使用普通素材，则从手卡·场上选择素材送墓后融合召唤；若选择连锁素材，则按连锁素材效果处理；最后调用CompleteProcedure完成融合怪兽登场。
function c29719112.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取tp当前可用的普通融合素材组，并排除对当前效果免疫的卡（免疫者不能作为融合素材）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29719112.spfilter1,nil,e)
	-- 使用普通素材组mg1，取得额外卡组中所有能够融合召唤的机械族融合怪兽，构成候选列表sg1。
	local sg1=Duel.GetMatchingGroup(c29719112.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 处理时再次获取连锁素材效果（与发动时判断一致）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，用其提供的素材组mg2和额外限制mf，计算额外卡组中可融合召唤的机械族融合怪兽，构成候选列表sg2。
		sg2=Duel.GetMatchingGroup(c29719112.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示特殊召唤选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断玩家选中的融合怪兽是否可走普通融合路线；若它也同时被连锁素材支持，则询问玩家是否使用连锁素材；否则或玩家选择不使用时进入普通融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让tp从普通素材组mg1中选择融合怪兽tc所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以效果·融合素材的原因送去墓地，作为融合召唤的素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使融合素材送墓和融合怪兽特殊召唤分成两个独立处理，避免错误地错过时点（例如素材送墓后能正常发动效果，特殊召唤成功时点也能被正确响应）。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到tp的怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材时，让tp从连锁素材提供的素材组mg2中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断战破的怪兽是否为融合怪兽，且其在战破前的控制者为tp（即自己的融合怪兽被战破）。
function c29719112.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp)
end
-- ③效果的发动条件：破坏送去墓地的怪兽组eg中，存在至少1只是自己控制的融合怪兽（即自己的融合怪兽被战斗破坏）。
function c29719112.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29719112.cfilter,1,nil,tp)
end
-- 检索目标过滤：必须是「力量结合」（卡号37630732），且能加入手卡（不受“不能加入手卡”效果限制）。
function c29719112.thfilter(c)
	return c:IsCode(37630732) and c:IsAbleToHand()
end
-- ③效果的目标检查：若卡组中存在可加入手卡的「力量结合」，则登记操作信息为从卡组检索1张加入手卡，允许发动。
function c29719112.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：检查卡组中是否存在至少1张满足thfilter的「力量结合」，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29719112.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记：本次操作会将卡组中的卡加入手卡（CATEGORY_TOHAND），用于连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：让tp从卡组选择1张「力量结合」加入手卡，并将检索到的卡展示给对方确认。
function c29719112.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让tp从卡组选择1张满足thfilter的「力量结合」（实际检索1张）。
	local g=Duel.SelectMatchingCard(tp,c29719112.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「力量结合」加入持有者（通常是tp）的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
