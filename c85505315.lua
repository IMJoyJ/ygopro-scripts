--インヴェルズ・マディス
-- 效果：
-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，可以支付1000基本分，选择自己墓地存在的1只名字带有「侵入魔鬼」的怪兽特殊召唤。
function c85505315.initial_effect(c)
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时，可以支付1000基本分，选择自己墓地存在的1只名字带有「侵入魔鬼」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85505315,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c85505315.condition)
	e1:SetCost(c85505315.cost)
	e1:SetTarget(c85505315.target)
	e1:SetOperation(c85505315.operation)
	c:RegisterEffect(e1)
	-- 把名字带有「侵入魔鬼」的怪兽解放对这张卡的上级召唤成功时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c85505315.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检查上级召唤的解放素材中是否存在名字带有「侵入魔鬼」的怪兽，并在主效果上做标记
function c85505315.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x100a) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判定这张卡是否上级召唤成功，且解放素材中包含名字带有「侵入魔鬼」的怪兽
function c85505315.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 支付1000基本分的Cost处理
function c85505315.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤出自己墓地中可以特殊召唤的名字带有「侵入魔鬼」的怪兽
function c85505315.filter(c,e,tp)
	return c:IsSetCard(0x100a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的靶向处理，检查怪兽区域空位并选择墓地中1只名字带有「侵入魔鬼」的怪兽作为对象
function c85505315.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c85505315.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象且能特殊召唤的名字带有「侵入魔鬼」的怪兽
		and Duel.IsExistingTarget(c85505315.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只名字带有「侵入魔鬼」的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85505315.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，将选择的墓地怪兽特殊召唤
function c85505315.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
