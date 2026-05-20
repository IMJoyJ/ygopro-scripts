--捕食植物バアル・テア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己的额外卡组（表侧）·墓地把1只「捕食植物」怪兽或「凶饿毒」怪兽特殊召唤。
-- ②：对方场上有怪兽特殊召唤的场合，从自己墓地把这张卡和1张「融合」除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「融合」（卡号24094653）加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,24094653)
	-- 注册一个检测这张卡是否已在墓地的状态标记效果，用于后续墓地诱发效果的合法性验证
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己的额外卡组（表侧）·墓地把1只「捕食植物」怪兽或「凶饿毒」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有怪兽特殊召唤的场合，从自己墓地把这张卡和1张「融合」除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡是通过同调召唤方式特殊召唤的
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的特殊召唤对象过滤：额外卡组表侧表示或墓地的「捕食植物」或「凶饿毒」怪兽，且能被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx()
		and c:IsSetCard(0x10f3,0x1050) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 若目标在墓地，则需要自己场上有可用的怪兽区域空格
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 若目标在额外卡组，则需要有可用于从额外卡组特殊召唤的空格
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果①的发动准备：检查是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地或额外卡组是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统注册特殊召唤的操作信息，涉及从额外卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果①的效果处理：从额外卡组（表侧）或墓地选择1只满足条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地（受王家长眠之谷影响）或额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤对方特殊召唤成功的怪兽，且排除因当前效果自身导致特殊召唤的情况
function s.spfilter2(c,tp,se)
	return c:IsControler(tp) and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件：对方场上有怪兽特殊召唤的场合，且该卡在对方特殊召唤前已存在于墓地
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter2,1,nil,1-tp,se)
end
-- 过滤墓地中可以作为代价除外的「融合」
function s.costfilter(c,exc,e,tp,eg,ep,ev,re,r,rp)
	return c:IsCode(24094653) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价处理：检查自身和墓地的「融合」是否可以除外
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在除自身以外的1张「融合」
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和这张卡一起除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤不受当前效果影响的怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可以进行融合召唤的融合怪兽，并检查素材是否充足
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②的发动准备：检查是否能用手卡·场上的怪兽作为素材融合召唤1只融合怪兽，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己手卡·场上可用的融合素材，并过滤掉不受效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组中是否存在可以使用上述素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下，是否存在可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向系统注册特殊召唤的操作信息，涉及从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：选择1只融合怪兽，将手卡·场上的怪兽送去墓地作为素材进行融合召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己手卡·场上可用的融合素材，并过滤掉不受效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用手卡·场上素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤（融合召唤）的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规的手卡·场上素材进行融合召唤（若可以使用连锁素材，则询问玩家是否使用）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
