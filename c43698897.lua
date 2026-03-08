--デストーイ・ファクトリー
-- 效果：
-- 「魔玩具工厂」的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1张「融合」魔法卡除外才能把这个效果发动。从自己的手卡·场上把「魔玩具」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡被送去墓地的场合，以除外的1张自己的「魔玩具融合」为对象才能发动。那张卡加入手卡。
function c43698897.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1张「融合」魔法卡除外才能把这个效果发动。从自己的手卡·场上把「魔玩具」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,43698897)
	e2:SetCost(c43698897.spcost)
	e2:SetTarget(c43698897.sptg)
	e2:SetOperation(c43698897.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以除外的1张自己的「魔玩具融合」为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,43698898)
	e3:SetTarget(c43698897.thtg)
	e3:SetOperation(c43698897.thop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「魔玩具」融合怪兽卡
function c43698897.spfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 将满足条件的「魔玩具」融合怪兽卡从墓地除外作为费用
function c43698897.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「魔玩具」融合怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c43698897.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的「魔玩具」融合怪兽卡
	local g=Duel.SelectMatchingCard(tp,c43698897.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断卡是否免疫效果
function c43698897.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断卡是否为融合怪兽且满足融合召唤条件
function c43698897.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xad) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 设置融合召唤效果的发动条件
function c43698897.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否有满足条件的融合怪兽卡
		local res=Duel.IsExistingMatchingCard(c43698897.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否有满足条件的融合怪兽卡
				res=Duel.IsExistingMatchingCard(c43698897.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤效果
function c43698897.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材，排除免疫效果的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c43698897.filter1,nil,e)
	-- 获取满足融合召唤条件的融合怪兽卡
	local sg1=Duel.GetMatchingGroup(c43698897.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足融合召唤条件的融合怪兽卡
		sg2=Duel.GetMatchingGroup(c43698897.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合素材
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
-- 检索满足条件的「魔玩具融合」卡
function c43698897.thfilter(c)
	return c:IsFaceup() and c:IsCode(6077601) and c:IsAbleToHand()
end
-- 设置手牌效果的发动条件
function c43698897.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c43698897.thfilter(chkc) end
	-- 检查是否有满足条件的「魔玩具融合」卡
	if chk==0 then return Duel.IsExistingTarget(c43698897.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「魔玩具融合」卡
	local g=Duel.SelectTarget(tp,c43698897.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置手牌效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行手牌效果
function c43698897.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
