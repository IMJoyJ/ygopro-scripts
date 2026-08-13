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
-- 筛选可作为代价的卡：卡名含有「融合」的魔法卡，并且能够从墓地除外作为发动代价。
function c43698897.spfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 发动代价函数：确认墓地存在可除外的「融合」魔法卡后，由玩家选择1张，将其表侧除外作为发动代价。
function c43698897.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1张满足条件的可除外「融合」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c43698897.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的「融合」魔法卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c43698897.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的「融合」魔法卡表侧表示除外，完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 素材过滤：排除对当前效果免疫的卡，确保可选素材不受效果免疫影响。
function c43698897.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 额外怪兽过滤：必须是「魔玩具」融合怪兽，能够以融合召唤方式特殊召唤，并且能与当前素材满足融合素材条件。
function c43698897.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xad) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动目标检查：确认额外卡组存在可用当前融合素材（或连锁素材）融合召唤的「魔玩具」融合怪兽，并设置特殊召唤操作信息。
function c43698897.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组（手卡·场上的怪兽及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在通过当前素材可融合召唤的「魔玩具」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c43698897.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家所受的连锁素材效果（若存在），用于扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 当存在连锁素材效果时，用其提供的素材组再次检查能否融合召唤「魔玩具」融合怪兽。
				res=Duel.IsExistingMatchingCard(c43698897.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果处理将进行从额外卡组的1只怪兽的特殊召唤（融合召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的实际处理：选出可融合召唤的「魔玩具」融合怪兽，选择素材并将其送去墓地，然后进行融合召唤；若使用连锁素材则按连锁素材的效果处理。
function c43698897.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前融合素材，并剔除对效果免疫的卡，避免选用无效素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c43698897.filter1,nil,e)
	-- 获取额外卡组中所有能用这些普通素材融合召唤的「魔玩具」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c43698897.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（若存在），用于扩展可选素材范围。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材提供的素材时额外卡组中可融合召唤的「魔玩具」融合怪兽。
		sg2=Duel.GetMatchingGroup(c43698897.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从候选融合怪兽中选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽能否用普通素材召唤：若只能用普通素材，或即使可用连锁素材但玩家选择不使用连锁素材，则走普通融合流程；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，作为融合召唤素材（效果·素材·融合原因）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的「魔玩具」融合怪兽特殊召唤到场。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材组中选择该融合怪兽所需的融合素材（当使用连锁素材时）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 回收目标过滤：除外的自己的表侧表示「魔玩具融合」，且能够加入手牌。
function c43698897.thfilter(c)
	return c:IsFaceup() and c:IsCode(6077601) and c:IsAbleToHand()
end
-- ②效果的发动条件与取对象：确认除外区存在符合条件的「魔玩具融合」，并以其中1张为对象。
function c43698897.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c43698897.thfilter(chkc) end
	-- 发动条件检查：确认自己除外的卡中存在满足条件的「魔玩具融合」卡。
	if chk==0 then return Duel.IsExistingTarget(c43698897.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1张自己的「魔玩具融合」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c43698897.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：本次效果处理后将对象卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的实际处理：将仍与效果关联的对象卡加入其持有者手牌。
function c43698897.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入手牌（效果处理后）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
