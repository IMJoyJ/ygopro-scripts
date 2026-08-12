--充電器
-- 效果：
-- 支付500基本分。从自己墓地特殊召唤1只名字带有「电池人」的怪兽。
function c61181383.initial_effect(c)
	-- 支付500基本分。从自己墓地特殊召唤1只名字带有「电池人」的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c61181383.cost)
	e1:SetTarget(c61181383.target)
	e1:SetOperation(c61181383.activate)
	c:RegisterEffect(e1)
end
-- 定义发动成本（Cost）函数：支付500基本分
function c61181383.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家是否能够支付500点基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除500点基本分作为发动成本
	Duel.PayLPCost(tp,500)
end
-- 过滤函数：筛选卡名含有「电池人」且可以特殊召唤的怪兽
function c61181383.filter(c,e,tp)
	return c:IsSetCard(0x28) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择（Target）函数
function c61181383.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61181383.filter(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己墓地是否存在满足条件的「电池人」怪兽
		and Duel.IsExistingTarget(c61181383.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在客户端显示提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「电池人」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61181383.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果处理（Operation）函数
function c61181383.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
