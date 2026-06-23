--超逸融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让卡的效果发动。
-- ①：支付2000基本分，以场上1只效果怪兽为对象才能发动。和那只怪兽是等级不同并是种族·属性相同的1只怪兽从额外卡组效果无效特殊召唤。那之后，从以下效果选1个适用。
-- ●这个效果特殊召唤的怪兽和作为对象的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ●这个效果特殊召唤的怪兽送去墓地。
local s,id,o=GetID()
-- 注册效果：将此卡设为发动时点，支付2000基本分，选择场上1只效果怪兽作为对象，从额外卡组特殊召唤与该怪兽种族属性相同但等级不同的1只怪兽，之后选择融合召唤或送去墓地的效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 支付2000基本分的费用处理
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 过滤函数：检查场上是否有满足条件的效果怪兽
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
		and c:GetLevel()>0
		-- 检查场上是否存在满足条件的额外卡组怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤函数：检查额外卡组中是否存在种族属性与目标怪兽相同但等级不同的怪兽
function s.spfilter(c,e,tp,tc)
	return c:IsAttribute(tc:GetAttribute())
		and c:IsRace(tc:GetRace())
		and c:GetLevel()>0
		and not c:IsLevel(tc:GetLevel())
		-- 检查该怪兽是否可以特殊召唤且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果目标：选择场上1只效果怪兽作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp) end
	-- 检查是否存在满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只效果怪兽作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤1只额外卡组怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制：禁止连锁其他效果
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 融合召唤特殊召唤过滤函数
function s.fspfilter(c,e,tp,mg,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and not mg:IsExists(Card.IsImmuneToEffect,1,nil,e)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end
-- 融合素材过滤函数
function s.ffilter(c,mg)
	return mg:IsContains(c)
end
-- 融合检查函数
function s.fcheck(mg)
	return function(tp,sg,fc)
				return sg:IsExists(s.ffilter,2,nil,mg)
			end
end
-- 效果发动处理：选择特殊召唤的怪兽，然后选择融合召唤或送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		if not g or g:GetCount()==0 then return end
		local fc=g:GetFirst()
		-- 特殊召唤该怪兽并设置效果
		if tc and Duel.SpecialSummonStep(fc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 使特殊召唤的怪兽无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			fc:RegisterEffect(e1)
			-- 使特殊召唤的怪兽效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			fc:RegisterEffect(e2)
			-- 完成特殊召唤步骤
			Duel.SpecialSummonComplete()
			local chkf=tp
			local mg=Group.FromCards(tc,fc)
			-- 设置融合检查附加条件
			aux.FCheckAdditional=s.fcheck
			-- 获取满足融合召唤条件的怪兽组
			local sg=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
			local b1=sg:GetCount()>0
			local b2=fc:IsAbleToGrave()
			-- 选择融合召唤或送去墓地的效果
			local op=aux.SelectFromOptions(tp,
				{b1,aux.Stringid(id,1),1},  --"融合召唤"
				{b2,aux.Stringid(id,2),2})  --"送去墓地"
			-- 中断当前效果处理
			Duel.BreakEffect()
			if op==1 then
				-- 提示玩家选择要特殊召唤的融合怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tfc=tg:GetFirst()
				-- 选择融合素材
				local mat=Duel.SelectFusionMaterial(tp,tfc,mg,nil,chkf)
				tfc:SetMaterial(mat)
				-- 将融合素材送去墓地
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 融合召唤融合怪兽
				Duel.SpecialSummon(tfc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				tfc:CompleteProcedure()
			elseif op==2 then
				-- 将特殊召唤的怪兽送去墓地
				Duel.SendtoGrave(fc,REASON_EFFECT)
			end
		end
	end
end
