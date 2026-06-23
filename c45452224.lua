--金華猫
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤·反转时，以自己墓地1只1星怪兽为对象才能发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽除外。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c45452224.initial_effect(c)
	-- 为卡片添加在召唤或反转成功时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转时，以自己墓地1只1星怪兽为对象才能发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(45452224,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetTarget(c45452224.sptg)
	e4:SetOperation(c45452224.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
	-- ①：这张卡召唤·反转时，以自己墓地1只1星怪兽为对象才能发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽除外。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetOperation(c45452224.leave)
	c:RegisterEffect(e6)
	e4:SetLabelObject(e6)
	e5:SetLabelObject(e6)
end
-- 筛选满足条件的1星怪兽（可特殊召唤）
function c45452224.filter(c,e,tp)
	return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且自己墓地存在1星怪兽
function c45452224.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45452224.filter(chkc,e,tp) end
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在1星怪兽
		and Duel.IsExistingTarget(c45452224.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1星怪兽作为目标
	local g=Duel.SelectTarget(tp,c45452224.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果：将目标怪兽特殊召唤到场上
function c45452224.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽和自身都存在于场上且未被无效
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		e:GetLabelObject():SetLabelObject(tc)
		c:CreateRelation(tc,RESET_EVENT+0x5020000)
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
	end
end
-- 处理离开场上的效果：将目标怪兽除外
function c45452224.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
		-- 将目标怪兽以效果原因除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
