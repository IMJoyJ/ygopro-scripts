--クロスローズ・ドラゴン
-- 效果：
-- 种族不同的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡和自己场上1只植物族怪兽解放才能发动。从额外卡组把1只「蔷薇」同调怪兽或者植物族同调怪兽当作同调召唤作特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的怪兽被效果破坏的场合，把墓地的这张卡除外才能发动。从自己墓地选1只「蔷薇龙」怪兽特殊召唤。
function c72218246.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2只种族不同的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2,c72218246.lcheck)
	-- ①：自己·对方的主要阶段，把这张卡和自己场上1只植物族怪兽解放才能发动。从额外卡组把1只「蔷薇」同调怪兽或者植物族同调怪兽当作同调召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72218246,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,72218246)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c72218246.spcon1)
	e1:SetCost(c72218246.spcost1)
	e1:SetTarget(c72218246.sptg1)
	e1:SetOperation(c72218246.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的怪兽被效果破坏的场合，把墓地的这张卡除外才能发动。从自己墓地选1只「蔷薇龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72218246,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,72218247)
	e2:SetCondition(c72218246.spcon2)
	-- 设置效果②的发动成本为：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c72218246.sptg2)
	e2:SetOperation(c72218246.spop2)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：检查素材怪兽的种族是否各不相同
function c72218246.lcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount()
end
-- 效果①的发动条件：自己或对方的主要阶段
function c72218246.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤自己场上可作为解放成本的植物族怪兽，且额外卡组存在可特殊召唤的同调怪兽
function c72218246.rfilter(c,e,tp,mc)
	-- 检查该卡是否为植物族，且在解放该卡和此卡后，额外卡组是否存在可特殊召唤的同调怪兽
	return c:IsRace(RACE_PLANT) and Duel.IsExistingMatchingCard(c72218246.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,mc))
end
-- 过滤额外卡组中满足条件的「蔷薇」同调怪兽或植物族同调怪兽
function c72218246.spfilter1(c,e,tp,mg)
	return c:IsType(TYPE_SYNCHRO) and (c:IsSetCard(0x123) or c:IsRace(RACE_PLANT))
		-- 检查该怪兽是否能以同调召唤的形式特殊召唤，且在解放素材后额外怪兽区域或主要怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 效果①的发动成本处理：将这张卡和自己场上1只植物族怪兽解放
function c72218246.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查此卡是否可解放，且场上是否存在至少1只满足过滤条件的可解放植物族怪兽
	if chk==0 then return c:IsReleasable() and Duel.CheckReleaseGroup(tp,c72218246.rfilter,1,c,e,tp,c) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择1只满足过滤条件的植物族怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c72218246.rfilter,1,1,c,e,tp,c)
	g:AddCard(c)
	-- 将选中的怪兽（包括此卡）作为发动成本解放
	Duel.Release(g,REASON_COST)
end
-- 效果①的靶向/发动准备：检查必须成为同调素材的限制，并设置特殊召唤的操作信息
function c72218246.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为同调素材的怪兽限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：从额外卡组将1只满足条件的同调怪兽当作同调召唤特殊召唤
function c72218246.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查必须作为同调素材的限制，若不满足则不处理效果
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「蔷薇」同调怪兽或植物族同调怪兽
	local g=Duel.SelectMatchingCard(tp,c72218246.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 尝试将选中的怪兽以同调召唤的形式表侧表示特殊召唤，并检查是否成功
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:CompleteProcedure()
		end
	end
end
-- 过滤被效果破坏的自己场上的怪兽
function c72218246.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- 效果②的发动条件：自己场上的怪兽被效果破坏，且被破坏的怪兽不包含此卡自身
function c72218246.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c72218246.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤自己墓地中可以特殊召唤的「蔷薇龙」怪兽
function c72218246.spfilter2(c,e,tp)
	return c:IsSetCard(0x1123) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向/发动准备：检查怪兽区域空位，并确认墓地中存在可特殊召唤的「蔷薇龙」怪兽
function c72218246.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在至少1只（除此卡外）可以特殊召唤的「蔷薇龙」怪兽
		and Duel.IsExistingMatchingCard(c72218246.spfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置效果处理信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：从自己墓地选择1只「蔷薇龙」怪兽特殊召唤
function c72218246.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只不受「王家长眠之谷」影响的「蔷薇龙」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c72218246.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「蔷薇龙」怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
