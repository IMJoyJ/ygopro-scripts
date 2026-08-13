--幻獣機サーバルホーク
-- 效果：
-- 这张卡不能直接攻击。自己墓地有名字带有「幻兽机」的怪兽以外的怪兽存在的场合，这张卡不能攻击。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。选择自己或者对方的墓地1张卡从游戏中除外。
function c15335853.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c15335853.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置效果条件：仅当自己场上有衍生物存在时，此战斗破坏免疫效果才适用。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 此外，1回合1次，把1只衍生物解放才能发动。选择自己或者对方的墓地1张卡从游戏中除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15335853,0))  --"卡片除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c15335853.rmcost)
	e4:SetTarget(c15335853.rmtg)
	e4:SetOperation(c15335853.rmop)
	c:RegisterEffect(e4)
	-- 这张卡不能直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
	-- 自己墓地有名字带有「幻兽机」的怪兽以外的怪兽存在的场合，这张卡不能攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	e6:SetCondition(c15335853.atcon)
	c:RegisterEffect(e6)
end
-- 计算自己场上所有「幻兽机衍生物」的等级合计，作为这张卡的等级上升数值。
function c15335853.lvval(e,c)
	local tp=c:GetControler()
	-- 返回自己场上所有「幻兽机衍生物」（卡号31533705）的等级合计数值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 定义发动代价：从自己场上选择1只衍生物解放作为发动成本。
function c15335853.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可作为解放对象的衍生物。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 让玩家从自己场上选择1只衍生物用于解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 以代价原因解放所选择的衍生物。
	Duel.Release(g,REASON_COST)
end
-- 定义目标筛选条件：该卡可以被除外。
function c15335853.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 设置效果发动时的目标选择：从自己或对方墓地选择1张可以被除外的卡，并记录其控制者及除外操作信息。
function c15335853.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c15335853.rmfilter(chkc) end
	-- 发动合法性检查：确认双方墓地存在至少1张可供选择且能被除外的卡。
	if chk==0 then return Duel.IsExistingTarget(c15335853.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 发送选择提示：要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己或对方墓地选择1张满足条件的卡作为效果对象，并自动与当前连锁建立对象关联。
	local g=Duel.SelectTarget(tp,c15335853.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local p=g:GetFirst():GetControler()
	-- 登记除外操作信息：预定了1张墓地卡将被除外（位置为墓地，持有者为p）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,p,LOCATION_GRAVE)
end
-- 效果处理：如果目标卡仍与效果关联，则将其从墓地除外。
function c15335853.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前效果处理的对象卡（此前选择的墓地卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以表侧表示除外（处理原因为效果）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 筛选条件：该卡是怪兽且字段不是「幻兽机」。
function c15335853.atfilter(c)
	return not c:IsSetCard(0x101b) and c:IsType(TYPE_MONSTER)
end
-- 判定条件：自己墓地存在至少1只名字带有「幻兽机」以外的怪兽。
function c15335853.atcon(e)
	-- 检查是否存在满足 atfilter 的卡，即自己墓地有没有非「幻兽机」怪兽。
	return Duel.IsExistingMatchingCard(c15335853.atfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
