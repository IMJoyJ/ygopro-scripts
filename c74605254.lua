--DD魔導賢者ガリレイ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：自己准备阶段发动。这张卡的灵摆刻度上升2（最多到10）。那之后，持有这张卡的灵摆刻度以下的等级的除「DD」怪兽以外的自己场上的怪兽全部破坏。
-- 【怪兽效果】
-- 「DD 魔导贤者 伽利莱」的怪兽效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃，以自己场上1张「DD」卡或者「契约书」卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
function c74605254.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（包括灵摆召唤和灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「DD」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c74605254.splimit)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。这张卡的灵摆刻度上升2（最多到10）。那之后，持有这张卡的灵摆刻度以下的等级的除「DD」怪兽以外的自己场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c74605254.sccon)
	e3:SetTarget(c74605254.sctg)
	e3:SetOperation(c74605254.scop)
	c:RegisterEffect(e3)
	-- ①：把这张卡从手卡丢弃，以自己场上1张「DD」卡或者「契约书」卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74605254,0))  --"卡片回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_HAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,74605254)
	e4:SetCost(c74605254.thcost)
	e4:SetTarget(c74605254.thtg)
	e4:SetOperation(c74605254.thop)
	c:RegisterEffect(e4)
end
-- 限制自身只能灵摆召唤「DD」怪兽的过滤函数。
function c74605254.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xaf) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 准备阶段灵摆刻度上升及破坏效果的发动条件函数。
function c74605254.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤自己场上表侧表示、非「DD」怪兽且等级在指定刻度以下的怪兽。
function c74605254.filter(c,lv)
	return c:IsFaceup() and not c:IsSetCard(0xaf) and c:IsLevelBelow(lv)
end
-- 准备阶段灵摆刻度上升及破坏效果的发动准备函数。
function c74605254.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local scl=math.min(10,e:GetHandler():GetLeftScale()+2)
	-- 获取自己场上满足破坏条件的怪兽组（非「DD」且等级在上升后的刻度以下）。
	local g=Duel.GetMatchingGroup(c74605254.filter,tp,LOCATION_MZONE,0,nil,scl)
	if e:GetHandler():GetLeftScale()<10 then
		-- 设置破坏操作的信息，包含预计破坏的怪兽组及数量。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 准备阶段灵摆刻度上升及破坏效果的执行函数。
function c74605254.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()>=10 then return end
	local scl=2
	if c:GetLeftScale()==9 then scl=1 end
	-- 这张卡的灵摆刻度上升2（最多到10）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetValue(scl)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
	-- 获取自己场上等级在当前灵摆刻度以下的除「DD」怪兽以外的怪兽。
	local g=Duel.GetMatchingGroup(c74605254.filter,tp,LOCATION_MZONE,0,nil,c:GetLeftScale())
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续的破坏处理与刻度上升不视为同时进行。
		Duel.BreakEffect()
		-- 将满足条件的怪兽全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 回收效果的发动代价函数。
function c74605254.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将手牌中的这张卡丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤自己场上表侧表示且可以回到手牌的「DD」卡或「契约书」卡。
function c74605254.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae,0xaf) and c:IsAbleToHand()
end
-- 回收效果的发动准备函数。
function c74605254.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c74605254.thfilter(chkc) end
	-- 检查自己场上是否存在可以回到手牌的「DD」卡或「契约书」卡。
	if chk==0 then return Duel.IsExistingTarget(c74605254.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择并锁定1张符合条件的卡作为效果对象。
	local g=Duel.SelectTarget(tp,c74605254.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置返回手牌操作的信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行函数。
function c74605254.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认返回手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
