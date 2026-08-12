--ツイン・トライアングル・ドラゴン
-- 效果：
-- 衍生物以外的4星以下的龙族怪兽2只
-- ①：这张卡连接召唤成功时，支付500基本分，以自己墓地1只5星以上的怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合不能攻击。
function c66015185.initial_effect(c)
	-- 添加连接召唤手续：需要2只满足过滤条件的怪兽作为素材
	aux.AddLinkProcedure(c,c66015185.mfilter,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功时，支付500基本分，以自己墓地1只5星以上的怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66015185,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c66015185.spcon)
	e1:SetCost(c66015185.spcost)
	e1:SetTarget(c66015185.sptg)
	e1:SetOperation(c66015185.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：4星以下的龙族怪兽且不能是衍生物
function c66015185.mfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_DRAGON) and not c:IsLinkType(TYPE_TOKEN)
end
-- 判断是否为连接召唤成功时发动
function c66015185.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 支付500基本分的Cost处理
function c66015185.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：墓地中5星以上且能特殊召唤到指定连接区的怪兽
function c66015185.filter(c,e,tp,zone)
	return c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果发动时的目标选择与操作信息设置
function c66015185.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66015185.filter(chkc,e,tp,zone) end
	-- 检查自己墓地是否存在符合条件的、可以特殊召唤到连接区的5星以上怪兽
	if chk==0 then return Duel.IsExistingTarget(c66015185.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c66015185.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置效果处理信息为：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽在连接区特殊召唤，并使其效果无效化、本回合不能攻击
function c66015185.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适应效果，且连接区仍有空位，并尝试将其以表侧表示特殊召唤到连接区
	if tc:IsRelateToEffect(e) and zone&0x1f~=0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 这个回合不能攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3,true)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
