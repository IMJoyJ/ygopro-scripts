--BF－砂塵のハルマッタン
-- 效果：
-- 「黑羽-沙尘之哈麦丹」的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「黑羽-沙尘之哈麦丹」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功时，以这张卡以外的自己场上1只「黑羽」怪兽为对象才能发动。这张卡的等级上升那只怪兽的等级数值。
function c77152542.initial_effect(c)
	-- 「黑羽-沙尘之哈麦丹」的①的方法的特殊召唤1回合只能有1次。①：自己场上有「黑羽-沙尘之哈麦丹」以外的「黑羽」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,77152542+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c77152542.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功时，以这张卡以外的自己场上1只「黑羽」怪兽为对象才能发动。这张卡的等级上升那只怪兽的等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c77152542.target)
	e2:SetOperation(c77152542.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「黑羽-沙尘之哈麦丹」以外的「黑羽」怪兽
function c77152542.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and not c:IsCode(77152542)
end
-- 特殊召唤规则的条件：自己主要怪兽区域有空位，且自己场上存在「黑羽-沙尘之哈麦丹」以外的「黑羽」怪兽
function c77152542.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的主要怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件（「黑羽-沙尘之哈麦丹」以外的「黑羽」）的怪兽
		and Duel.IsExistingMatchingCard(c77152542.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己场上表侧表示、等级在1以上且属于「黑羽」系列的怪兽
function c77152542.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and c:IsLevelAbove(1)
end
-- 效果②的靶向处理：检查并选择自己场上1只这张卡以外的表侧表示「黑羽」怪兽作为对象
function c77152542.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c77152542.filter(chkc) and chkc~=e:GetHandler() end
	-- 在发动效果的准备阶段，检查自己场上是否存在除这张卡以外、满足过滤条件的表侧表示「黑羽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c77152542.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只除这张卡以外的表侧表示「黑羽」怪兽作为效果对象
	Duel.SelectTarget(tp,c77152542.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果②的效果处理：若对象怪兽和这张卡均在场上表侧表示存在，则这张卡的等级上升该对象怪兽的等级数值
function c77152542.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级上升那只怪兽的等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
