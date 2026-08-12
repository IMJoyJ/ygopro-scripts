--閃刀姫－カガリ
-- 效果：
-- 炎属性以外的「闪刀姬」怪兽1只
-- 自己对「闪刀姬-燎里」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤的场合，以自己墓地1张「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡的攻击力上升自己墓地的魔法卡数量×100。
function c63288573.initial_effect(c)
	c:SetSPSummonOnce(63288573)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要1只满足过滤条件的怪兽作为连接素材。
	aux.AddLinkProcedure(c,c63288573.matfilter,1,1)
	-- ②：这张卡的攻击力上升自己墓地的魔法卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(c63288573.atkval)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤的场合，以自己墓地1张「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63288573,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c63288573.thtg)
	e3:SetOperation(c63288573.thop)
	c:RegisterEffect(e3)
end
-- 过滤连接素材，必须是炎属性以外的「闪刀姬」怪兽。
function c63288573.matfilter(c)
	return c:IsLinkSetCard(0x1115) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_FIRE)
end
-- 计算攻击力上升值的函数，返回自己墓地的魔法卡数量×100。
function c63288573.atkval(e)
	-- 获取自己墓地的魔法卡数量并乘以100。
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_SPELL)*100
end
-- 过滤自己墓地中可以加入手牌的「闪刀」魔法卡。
function c63288573.thfilter(c,tp)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择（Target阶段）。
function c63288573.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63288573.thfilter(chkc) end
	-- 在发动时，检查自己墓地是否存在至少1张满足条件的「闪刀」魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c63288573.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在客户端显示提示信息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的「闪刀」魔法卡作为效果对象。
	local sg=Duel.SelectTarget(tp,c63288573.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表明此效果会将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果①的效果处理（Operation阶段）。
function c63288573.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
