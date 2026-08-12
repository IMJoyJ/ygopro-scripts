--デストーイ・マイスター
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：把自己场上的4星以下的「魔玩具」、「毛绒动物」、「锋利小鬼」怪兽的其中1只解放才能发动。和解放的怪兽相同等级而卡名不同的1只恶魔族怪兽从卡组特殊召唤。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把4星以下的「魔玩具」、「毛绒动物」、「锋利小鬼」怪兽的其中1只特殊召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：把自己场上的恶魔族怪兽2只以上解放才能发动。把持有和那个原本等级合计相同等级的1只「魔玩具」融合怪兽当作融合召唤从额外卡组特殊召唤。
function c77522571.initial_effect(c)
	-- 启用灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	-- ①：把自己场上的4星以下的「魔玩具」、「毛绒动物」、「锋利小鬼」怪兽的其中1只解放才能发动。和解放的怪兽相同等级而卡名不同的1只恶魔族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77522571,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,77522571)
	e1:SetCost(c77522571.spcost1)
	e1:SetTarget(c77522571.sptg1)
	e1:SetOperation(c77522571.spop1)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从卡组把4星以下的「魔玩具」、「毛绒动物」、「锋利小鬼」怪兽的其中1只特殊召唤。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77522571,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,77522572)
	e2:SetTarget(c77522571.sptg2)
	e2:SetOperation(c77522571.spop2)
	c:RegisterEffect(e2)
	-- ②：把自己场上的恶魔族怪兽2只以上解放才能发动。把持有和那个原本等级合计相同等级的1只「魔玩具」融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77522571,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,77522573)
	e3:SetCost(c77522571.spcost3)
	e3:SetTarget(c77522571.sptg3)
	e3:SetOperation(c77522571.spop3)
	c:RegisterEffect(e3)
end
-- 过滤可作为灵摆效果发动代价解放的4星以下「魔玩具」、「毛绒动物」或「锋利小鬼」怪兽。
function c77522571.costfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xa9,0xad,0xc3)
		-- 检查解放该怪兽后是否有可用的怪兽区域，且该怪兽必须由自己控制或是场上表侧表示的。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在满足特殊召唤条件的恶魔族怪兽。
		and Duel.IsExistingMatchingCard(c77522571.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel(),c:GetCode())
end
-- 过滤卡组中与被解放怪兽等级相同且卡名不同的可特殊召唤的恶魔族怪兽。
function c77522571.spfilter1(c,e,tp,lv,code)
	return c:IsRace(RACE_FIEND) and c:IsLevel(lv) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的代价处理：选择并解放1只满足条件的怪兽，并记录其等级和卡名。
function c77522571.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可解放的满足条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c77522571.costfilter1,1,nil,e,tp) end
	-- 玩家选择1只满足条件的怪兽作为解放对象。
	local rg=Duel.SelectReleaseGroup(tp,c77522571.costfilter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	e:SetValue(rg:GetFirst():GetCode())
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(rg,REASON_COST)
end
-- 灵摆效果的目标处理：设置特殊召唤的操作信息。
function c77522571.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果的运行处理：从卡组特殊召唤1只与解放怪兽等级相同且卡名不同的恶魔族怪兽。
function c77522571.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	local code=e:GetValue()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只与解放怪兽等级相同且卡名不同的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,c77522571.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv,code)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中4星以下的「魔玩具」、「毛绒动物」或「锋利小鬼」怪兽。
function c77522571.spfilter2(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xa9,0xad,0xc3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果①的目标处理：检查怪兽区域空位及卡组中是否存在可特殊召唤的怪兽。
function c77522571.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的4星以下「魔玩具」、「毛绒动物」或「锋利小鬼」怪兽。
		and Duel.IsExistingMatchingCard(c77522571.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的运行处理：特殊召唤怪兽，并适用“这个回合，自己不是融合怪兽不能从额外卡组特殊召唤”的限制。
function c77522571.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只4星以下的「魔玩具」、「毛绒动物」或「锋利小鬼」怪兽。
		local g=Duel.SelectMatchingCard(tp,c77522571.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。②：把自己场上的恶魔族怪兽2只以上解放才能发动。把持有和那个原本等级合计相同等级的1只「魔玩具」融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c77522571.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤融合怪兽以外怪兽的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能从额外卡组特殊召唤融合怪兽。
function c77522571.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤场上有等级的恶魔族怪兽。
function c77522571.costfilter(c)
	return c:IsLevelAbove(1) and c:IsRace(RACE_FIEND)
end
-- 检查选中的解放怪兽组合是否合法（可被解放，且额外卡组存在对应等级合计的「魔玩具」融合怪兽）。
function c77522571.fgoal(sg,e,tp)
	local lv=sg:GetSum(Card.GetLevel)
	-- 检查选中的怪兽组是否全部可以被解放。
	return Duel.CheckReleaseGroup(tp,aux.IsInGroup,#sg,nil,sg)
		-- 检查额外卡组是否存在等级与解放怪兽原本等级合计相同且满足特殊召唤条件的「魔玩具」融合怪兽。
		and Duel.IsExistingMatchingCard(c77522571.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv,sg)
end
-- 过滤额外卡组中等级与解放怪兽原本等级合计相同、可当作融合召唤特殊召唤的「魔玩具」融合怪兽。
function c77522571.spfilter3(c,e,tp,lv,sg)
	return c:IsSetCard(0xad) and c:IsType(TYPE_FUSION) and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 检查在解放选中的怪兽后，是否有足够的额外怪兽区域用于特殊召唤该融合怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
-- 怪兽效果②的代价处理：选择并解放2只以上的恶魔族怪兽，并记录它们的等级合计。
function c77522571.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可解放的恶魔族怪兽。
	local rg=Duel.GetReleaseGroup(tp):Filter(c77522571.costfilter,nil)
	if chk==0 then return rg:CheckSubGroup(c77522571.fgoal,2,rg:GetCount(),e,tp) end
	local g=rg:SelectSubGroup(tp,c77522571.fgoal,false,2,rg:GetCount(),e,tp)
	local lv=g:GetSum(Card.GetLevel)
	e:SetLabel(lv)
	-- 适用代替解放等相关效果的次数限制。
	aux.UseExtraReleaseCount(g,tp)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 怪兽效果②的目标处理：检查融合素材限制并设置特殊召唤的操作信息。
function c77522571.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为融合素材的卡片限制。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	-- 设置特殊召唤操作信息，表示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果②的运行处理：将1只原本等级合计相同等级的「魔玩具」融合怪兽当作融合召唤从额外卡组特殊召唤。
function c77522571.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 检查并确保满足必须作为融合素材的卡片限制。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只等级与解放怪兽原本等级合计相同且满足条件的「魔玩具」融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c77522571.spfilter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 尝试将选中的怪兽当作融合召唤特殊召唤，若成功则进行后续处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:CompleteProcedure()
		end
	end
end
