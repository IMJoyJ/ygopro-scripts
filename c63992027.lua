--二重光波
-- 效果：
-- ①：场上的攻击力最高的怪兽在对方场上存在的场合，以自己场上的持有超量素材的1只「银河眼」超量怪兽或者「光波」超量怪兽为对象才能发动。那只超量怪兽的超量素材全部取除，把1只那只超量怪兽的同名怪兽从额外卡组特殊召唤。
function c63992027.initial_effect(c)
	-- ①：场上的攻击力最高的怪兽在对方场上存在的场合，以自己场上的持有超量素材的1只「银河眼」超量怪兽或者「光波」超量怪兽为对象才能发动。那只超量怪兽的超量素材全部取除，把1只那只超量怪兽的同名怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c63992027.condition)
	e1:SetTarget(c63992027.target)
	e1:SetOperation(c63992027.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：场上攻击力最高的怪兽是否在对方场上存在
function c63992027.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤自己场上表侧表示、持有超量素材的「银河眼」或「光波」超量怪兽，且额外卡组存在其同名怪兽
function c63992027.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x107b,0xe5) and c:GetOverlayCount()>0
		-- 检查额外卡组是否存在可以特殊召唤的该怪兽的同名怪兽
		and (not e or Duel.IsExistingMatchingCard(c63992027.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c))
end
-- 过滤额外卡组中与目标怪兽同名、可以特殊召唤且有可用额外怪兽区域的怪兽
function c63992027.spfilter(c,e,tp,ec)
	-- 检查卡片是否与目标怪兽同名、是否能被特殊召唤，以及额外怪兽区域是否有空位
	return c:IsCode(ec:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的对象选择与操作信息注册
function c63992027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c63992027.filter(chkc,nil,nil) end
	-- 检查自己场上是否存在满足条件的可选择为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c63992027.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的超量怪兽作为对象
	Duel.SelectTarget(tp,c63992027.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 注册效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将目标怪兽的超量素材全部送去墓地，并从额外卡组特殊召唤1只同名怪兽
function c63992027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local og=tc:GetOverlayGroup()
	if og:GetCount()==0 then return end
	-- 成功将目标怪兽的所有超量素材送去墓地的场合
	if Duel.SendtoGrave(og,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只与目标怪兽同名的怪兽
		local g=Duel.SelectMatchingCard(tp,c63992027.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选择的同名怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
