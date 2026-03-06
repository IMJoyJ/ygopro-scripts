--雨の天気模様
-- 效果：
-- ①：「雨之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●把这张卡除外，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
function c27561302.initial_effect(c)
	c:SetUniqueOnField(1,0,27561302)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：●把这张卡除外，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27561302,0))  --"魔法·陷阱卡回到持有者手卡（雨之天气模样）"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27561302.thtg)
	e2:SetOperation(c27561302.thop)
	-- 效果原文内容：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c27561302.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为「天气」效果怪兽且位于与场地卡同纵列或相邻纵列的主要怪兽区域
function c27561302.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 检索满足条件的魔法·陷阱卡
function c27561302.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果目标为对方场上的魔法·陷阱卡
function c27561302.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c27561302.thfilter(chkc) end
	-- 检查是否有满足条件的魔法·陷阱卡存在
	if chk==0 then return Duel.IsExistingTarget(c27561302.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示发动了此效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c27561302.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息为将对象卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果的发动与结算
function c27561302.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
