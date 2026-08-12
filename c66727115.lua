--武神逐
-- 效果：
-- 把自己场上1只名字带有「武神」的兽战士族怪兽解放才能发动。从自己墓地选择和那只怪兽的卡名不同的1只名字带有「武神」的怪兽特殊召唤。
function c66727115.initial_effect(c)
	-- 把自己场上1只名字带有「武神」的兽战士族怪兽解放才能发动。从自己墓地选择和那只怪兽的卡名不同的1只名字带有「武神」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c66727115.cost)
	e1:SetTarget(c66727115.target)
	e1:SetOperation(c66727115.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上可解放的「武神」兽战士族怪兽，且墓地存在与其卡名不同的可特殊召唤的「武神」怪兽
function c66727115.rfilter(c,e,tp)
	return c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
		-- 检查自己墓地是否存在至少1只与该怪兽卡名不同且可以特殊召唤的「武神」怪兽作为效果对象
		and Duel.IsExistingTarget(c66727115.spfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetCode(),e,tp)
end
-- 过滤条件：自己墓地中与被解放怪兽卡名不同、且可以特殊召唤的「武神」怪兽
function c66727115.spfilter(c,code,e,tp)
	return c:IsSetCard(0x88) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价（Cost）处理：设置标记以表明正在进行发动条件的检测，并返回true
function c66727115.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果发动时的目标选择与处理（Target）：检测发动条件、解放怪兽作为Cost、并选择墓地的「武神」怪兽作为效果对象
function c66727115.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c66727115.spfilter(chkc,e:GetLabel(),e,tp) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足过滤条件的可解放怪兽
		return Duel.CheckReleaseGroup(tp,c66727115.rfilter,1,nil,e,tp)
	end
	-- 玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c66727115.rfilter,1,1,nil,e,tp)
	local code=g:GetFirst():GetCode()
	e:SetLabel(code)
	-- 将选择的怪兽解放作为发动的代价（Cost）
	Duel.Release(g,REASON_COST)
	-- 给玩家发送提示信息：“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只与解放怪兽卡名不同的「武神」怪兽作为效果对象
	local sg=Duel.SelectTarget(tp,c66727115.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,code,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，操作对象为选择的墓地怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
-- 效果处理（Operation）：将选择的墓地怪兽特殊召唤
function c66727115.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
