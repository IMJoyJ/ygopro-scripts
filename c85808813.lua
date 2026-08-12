--タイム・ストリーム
-- 效果：
-- ①：以自己场上1只「化石」融合怪兽为对象才能发动。那只怪兽解放，原本等级比那只怪兽高2星的1只「化石」融合怪兽当作「化石融合」的融合召唤从额外卡组特殊召唤。
-- ②：从自己墓地把这张卡和1只「化石」融合怪兽除外，以自己墓地1只「化石」融合怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c85808813.initial_effect(c)
	-- 记录这张卡上记载了「化石融合」的卡名
	aux.AddCodeList(c,59419719)
	-- ①：以自己场上1只「化石」融合怪兽为对象才能发动。那只怪兽解放，原本等级比那只怪兽高2星的1只「化石」融合怪兽当作「化石融合」的融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85808813,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85808813.target)
	e1:SetOperation(c85808813.activate)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只「化石」融合怪兽除外，以自己墓地1只「化石」融合怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85808813,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置该效果在送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	e2:SetCost(c85808813.spcost)
	e2:SetTarget(c85808813.sptg)
	e2:SetOperation(c85808813.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上可以解放且额外卡组有对应高2星怪兽的「化石」融合怪兽
function c85808813.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x149) and c:IsType(TYPE_FUSION) and c:IsReleasableByEffect()
		-- 检查额外卡组是否存在原本等级比该怪兽高2星且可以特殊召唤的「化石」融合怪兽
		and Duel.IsExistingMatchingCard(c85808813.ffilter,tp,LOCATION_EXTRA,0,1,nil,c:GetOriginalLevel(),e,tp,c)
end
-- 过滤额外卡组中原本等级比目标怪兽高2星、可以特殊召唤且有可用额外怪兽区域出场的「化石」融合怪兽
function c85808813.ffilter(c,lv,e,tp,tc)
	return c:IsSetCard(0x149) and c:IsType(TYPE_FUSION) and c:GetOriginalLevel()==lv+2
		-- 检查该卡是否能以「化石融合」的融合召唤方式特殊召唤，且在解放目标怪兽后有可用的额外怪兽区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_FOSSIL_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 过滤自己场上表侧表示的「化石」融合怪兽
function c85808813.chkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x149) and c:IsType(TYPE_FUSION)
end
-- 效果①的发动准备与目标选择
function c85808813.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsReleasableByEffect()
		and chkc:IsFaceup() and chkc:IsSetCard(0x149) and chkc:IsType(TYPE_FUSION) end
	-- 检查自己场上是否存在符合条件的「化石」融合怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c85808813.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只「化石」融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85808813.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤额外卡组怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置解放目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- 效果①的处理（解放目标怪兽，并从额外卡组特殊召唤高2星的「化石」融合怪兽）
function c85808813.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetOriginalLevel()
	-- 解放目标怪兽，若解放失败则不继续处理
	if Duel.Release(tc,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只原本等级比解放怪兽高2星的「化石」融合怪兽
	local sg=Duel.SelectMatchingCard(tp,c85808813.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,nil)
	if sg:GetCount()>0 then
		sg:GetFirst():SetMaterial(nil)
		-- 将选择的怪兽当作「化石融合」的融合召唤特殊召唤
		Duel.SpecialSummon(sg,SUMMON_VALUE_FOSSIL_FUSION,tp,tp,false,false,POS_FACEUP)
		sg:GetFirst():CompleteProcedure()
	end
end
-- 过滤自己墓地中可以作为Cost除外的「化石」融合怪兽，且该怪兽除外后墓地仍有其他「化石」融合怪兽可作为特殊召唤的对象
function c85808813.cfilter(c,e,tp)
	return c:IsSetCard(0x149) and c:IsType(TYPE_FUSION) and c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在除当前卡以外的、可以特殊召唤的「化石」融合怪兽
		and Duel.IsExistingTarget(c85808813.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤自己墓地中可以特殊召唤的「化石」融合怪兽
function c85808813.spfilter(c,e,tp)
	return c:IsSetCard(0x149) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动Cost处理（将墓地的这张卡和1只「化石」融合怪兽除外）
function c85808813.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己墓地中是否存在可作为Cost除外的「化石」融合怪兽
		and Duel.IsExistingMatchingCard(c85808813.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只「化石」融合怪兽作为Cost除外
	local g=Duel.SelectMatchingCard(tp,c85808813.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和墓地的这张卡一起除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与目标选择
function c85808813.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85808813.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「化石」融合怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85808813.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤目标怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理（特殊召唤墓地的目标怪兽）
function c85808813.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
