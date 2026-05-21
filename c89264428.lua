--ベアルクティ・ビッグディッパー
-- 效果：
-- ①：1回合1次，自己的「北极天熊」怪兽为让效果发动而把怪兽解放的场合，可以作为代替把自己墓地1只7星以上的「北极天熊」怪兽除外。
-- ②：每次怪兽特殊召唤给这张卡放置1个指示物。
-- ③：1回合1次，怪兽特殊召唤的场合，把7个以上的这张卡的指示物全部取除，以对方场上1只怪兽为对象才能发动。得到那个控制权。这个效果在场上有「北极天熊」同调怪兽存在的场合才能发动。
function c89264428.initial_effect(c)
	c:EnableCounterPermit(0x5b)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己的「北极天熊」怪兽为让效果发动而把怪兽解放的场合，可以作为代替把自己墓地1只7星以上的「北极天熊」怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(89264428)
	e2:SetCountLimit(1)
	e2:SetTarget(c89264428.repfilter)
	e2:SetTargetRange(LOCATION_GRAVE,0)
	c:RegisterEffect(e2)
	-- ②：每次怪兽特殊召唤给这张卡放置1个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(c89264428.ctop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，怪兽特殊召唤的场合，把7个以上的这张卡的指示物全部取除，以对方场上1只怪兽为对象才能发动。得到那个控制权。这个效果在场上有「北极天熊」同调怪兽存在的场合才能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(89264428,0))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c89264428.tkccon)
	e4:SetCost(c89264428.tkccost)
	e4:SetTarget(c89264428.tkctg)
	e4:SetOperation(c89264428.tkcop)
	c:RegisterEffect(e4)
end
-- 过滤墓地中等级7星以上且是「北极天熊」的怪兽（作为代替除外的卡）
function c89264428.repfilter(e,c)
	return c:IsLevelAbove(7) and c:IsSetCard(0x163)
end
-- 每次怪兽特殊召唤成功时，给这张卡放置1个指示物
function c89264428.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x5b,1)
end
-- 过滤场上表侧表示的「北极天熊」同调怪兽
function c89264428.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163) and c:IsType(TYPE_SYNCHRO)
end
-- 效果③的发动条件：检查场上是否存在「北极天熊」同调怪兽
function c89264428.tkccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上（双方怪兽区）是否存在至少1只表侧表示的「北极天熊」同调怪兽
	return Duel.IsExistingMatchingCard(c89264428.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果③的代价：检查并取除这张卡上所有的指示物（至少7个）
function c89264428.tkccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x5b,7,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x5b,e:GetHandler():GetCounter(0x5b),REASON_COST)
end
-- 效果③的发动准备：检查是否满足发动条件，并选择对方场上1只可以改变控制权的怪兽作为对象
function c89264428.tkctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 发动检查：检查对方场上是否存在至少1只可以改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		and c89264428.tkccon(e,tp,eg,ep,ev,re,r,rp) end
	-- 设置选择卡片时的提示信息为“请选择要改变控制权的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以改变控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁运营信息：操作分类为改变控制权，对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果③的效果处理：获取对象怪兽并转移其控制权给发动效果的玩家
function c89264428.tkcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让发动效果的玩家得到该怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
