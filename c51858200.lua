--捕食惑星
-- 效果：
-- 「捕食惑星」的①的效果1回合只能使用1次。
-- ①：这张卡在魔法与陷阱区域存在，有捕食指示物放置的怪兽从场上离开的场合发动。从卡组把1张「捕食」卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的场合，不是「捕食植物」怪兽不能作为融合素材。
function c51858200.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡在魔法与陷阱区域存在，有捕食指示物放置的怪兽从场上离开的场合发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetRange(LOCATION_SZONE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c51858200.regop)
	c:RegisterEffect(e0)
	-- 效果原文内容：②：把墓地的这张卡除外才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的场合，不是「捕食植物」怪兽不能作为融合素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51858200,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,51858200)
	e2:SetCondition(c51858200.thcon)
	e2:SetTarget(c51858200.thtg)
	e2:SetOperation(c51858200.thop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	-- 效果原文内容：「捕食惑星」的①的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51858200,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c51858200.sptg)
	e3:SetOperation(c51858200.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在放置了捕食指示物的怪兽
function c51858200.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetCounter(0x1041)>0
end
-- 当有怪兽离开场上的时候，检查是否有放置了捕食指示物的怪兽离开，若有则设置标签为1
function c51858200.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c51858200.cfilter,1,nil) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 判断是否触发效果①，即上一个效果是否检测到有放置了捕食指示物的怪兽离开
function c51858200.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 过滤函数，用于检索卡组中「捕食」卡
function c51858200.thfilter(c)
	return c:IsSetCard(0xf3) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将要从卡组检索一张「捕食」卡加入手牌
function c51858200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将要从卡组检索一张「捕食」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 选择并把符合条件的「捕食」卡加入手牌，并确认对方看到该卡
function c51858200.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「捕食」卡
	local g=Duel.SelectMatchingCard(tp,c51858200.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于筛选融合素材中属于「捕食植物」的怪兽
function c51858200.spfilter1(c,e)
	return c:IsSetCard(0x10f3) and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选可以被特殊召唤的融合怪兽
function c51858200.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤函数，用于筛选可以作为融合素材的「捕食植物」怪兽
function c51858200.spfilter3(c)
	return c:IsCanBeFusionMaterial() and c:IsSetCard(0x10f3)
end
-- 设置连锁操作信息，表示将要从额外卡组融合召唤一只怪兽
function c51858200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材，并筛选出属于「捕食植物」的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsSetCard,nil,0x10f3)
		-- 检查是否存在满足条件的融合怪兽可以被特殊召唤
		local res=Duel.IsExistingMatchingCard(c51858200.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(c51858200.spfilter3,nil)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材效果的融合怪兽可以被特殊召唤
				res=Duel.IsExistingMatchingCard(c51858200.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将要从额外卡组融合召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理融合召唤的效果，包括选择融合怪兽、选择融合素材并进行融合召唤
function c51858200.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材，并筛选出属于「捕食植物」的怪兽作为第一种融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c51858200.spfilter1,nil,e)
	-- 获取所有可以被特殊召唤的融合怪兽
	local sg1=Duel.GetMatchingGroup(c51858200.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(c51858200.spfilter3,nil)
		local mf=ce:GetValue()
		-- 获取所有可以被特殊召唤的融合怪兽（基于连锁融合素材效果）
		sg2=Duel.GetMatchingGroup(c51858200.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一种融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择用于融合召唤的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择用于连锁融合召唤的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
