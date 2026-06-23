--幻獣機サーバルホーク
-- 效果：
-- 这张卡不能直接攻击。自己墓地有名字带有「幻兽机」的怪兽以外的怪兽存在的场合，这张卡不能攻击。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。选择自己或者对方的墓地1张卡从游戏中除外。
function c15335853.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c15335853.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 检查场上是否存在衍生物
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 1回合1次，把1只衍生物解放才能发动。选择自己或者对方的墓地1张卡从游戏中除外
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
	-- 这张卡不能直接攻击
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
	-- 自己墓地有名字带有「幻兽机」的怪兽以外的怪兽存在的场合，这张卡不能攻击
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	e6:SetCondition(c15335853.atcon)
	c:RegisterEffect(e6)
end
-- 计算场上幻兽机衍生物的等级总和
function c15335853.lvval(e,c)
	local tp=c:GetControler()
	-- 检索场上所有幻兽机衍生物并求和其等级
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 支付效果代价，解放1只衍生物
function c15335853.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足解放衍生物的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 选择1只可解放的衍生物
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选中的衍生物解放作为代价
	Duel.Release(g,REASON_COST)
end
-- 除外效果的可用目标过滤器
function c15335853.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 选择并设置除外效果的目标
function c15335853.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c15335853.rmfilter(chkc) end
	-- 判断是否存在可除外的目标
	if chk==0 then return Duel.IsExistingTarget(c15335853.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张可除外的墓地卡
	local g=Duel.SelectTarget(tp,c15335853.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local p=g:GetFirst():GetControler()
	-- 设置效果操作信息，确定除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,p,LOCATION_GRAVE)
end
-- 执行除外效果
function c15335853.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 攻击条件的过滤器，判断墓地是否有非幻兽机怪兽
function c15335853.atfilter(c)
	return not c:IsSetCard(0x101b) and c:IsType(TYPE_MONSTER)
end
-- 判断墓地是否存在非幻兽机怪兽
function c15335853.atcon(e)
	-- 判断墓地是否存在非幻兽机怪兽
	return Duel.IsExistingMatchingCard(c15335853.atfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
