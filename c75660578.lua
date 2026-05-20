--死の王 ヘル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「死界王战 赫尔女王」在自己场上只能有1只表侧表示存在。
-- ②：把自己场上1只「王战」怪兽或者不死族怪兽解放，以和那只怪兽卡名不同的自己墓地1只「王战」怪兽或者不死族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果在对方回合也能发动。
function c75660578.initial_effect(c)
	c:SetUniqueOnField(1,0,75660578)
	-- 把自己场上1只「王战」怪兽或者不死族怪兽解放，以和那只怪兽卡名不同的自己墓地1只「王战」怪兽或者不死族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75660578,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,75660578)
	e1:SetCost(c75660578.spcost)
	e1:SetTarget(c75660578.sptg)
	e1:SetOperation(c75660578.spop)
	c:RegisterEffect(e1)
end
-- 过滤作为解放代价的自己场上的「王战」怪兽或不死族怪兽
function c75660578.costfilter(c,e,tp)
	-- 检查卡片是否为「王战」怪兽或不死族怪兽，且该卡解放后能腾出可用的怪兽区域
	return (c:IsSetCard(0x134) or c:IsRace(RACE_ZOMBIE)) and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己墓地是否存在至少1只与该卡卡名不同、且满足特殊召唤条件的「王战」怪兽或不死族怪兽作为效果对象
		and Duel.IsExistingTarget(c75660578.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 过滤自己墓地中与解放怪兽卡名不同、且可以守备表示特殊召唤的「王战」怪兽或不死族怪兽
function c75660578.spfilter(c,e,tp,code)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_ZOMBIE)) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的代价处理：选择并解放自己场上1只满足条件的「王战」怪兽或不死族怪兽，并记录其卡名
function c75660578.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付解放1只满足条件的「王战」怪兽或不死族怪兽的代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,c75660578.costfilter,1,nil,e,tp) end
	-- 玩家选择1只满足条件的「王战」怪兽或不死族怪兽作为解放的代价
	local g=Duel.SelectReleaseGroup(tp,c75660578.costfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选择的怪兽作为代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果发动的对象选择与操作信息注册
function c75660578.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local code=e:GetLabel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c75660578.spfilter(chkc,e,tp,code) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只与解放怪兽卡名不同的「王战」怪兽或不死族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75660578.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,code)
	-- 设置效果处理信息为：特殊召唤选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽守备表示特殊召唤
function c75660578.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
