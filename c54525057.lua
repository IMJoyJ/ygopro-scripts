--星辰のパラディオン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：这张卡往连接怪兽所连接区的召唤·特殊召唤成功的场合，以「星辰之圣像骑士」以外的自己墓地1张「圣像骑士」卡为对象才能发动。那张卡加入手卡。
function c54525057.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,54525057+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c54525057.spcon)
	e1:SetValue(c54525057.spval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡往连接怪兽所连接区的召唤·特殊召唤成功的场合，以「星辰之圣像骑士」以外的自己墓地1张「圣像骑士」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54525057,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,54525058)
	e2:SetCondition(c54525057.thcon)
	e2:SetTarget(c54525057.thtg)
	e2:SetOperation(c54525057.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件：判断自身控制者的场上是否存在连接怪兽所连接的可用怪兽区域
function c54525057.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有连接怪兽所指向的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 判断在连接怪兽指向的区域中，是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的数值设定：指定特殊召唤到连接怪兽指向的区域
function c54525057.spval(e,c)
	-- 返回特殊召唤的区域限制，即自身控制者场上连接怪兽指向的区域
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- 效果发动的条件：判断这张卡是否被召唤·特殊召唤到连接怪兽指向的区域
function c54525057.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取从自己视角来看，双方场上处于连接状态的怪兽组
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取从对方视角来看，双方场上处于连接状态的怪兽组
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 过滤条件：自己墓地「星辰之圣像骑士」以外的「圣像骑士」卡，且能加入手卡
function c54525057.thfilter(c)
	return c:IsSetCard(0x116) and not c:IsCode(54525057) and c:IsAbleToHand()
end
-- 效果发动的目标：选择自己墓地1张符合条件的「圣像骑士」卡作为对象
function c54525057.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c54525057.thfilter(chkc) end
	-- 在效果发动阶段，检查自己墓地是否存在可以作为对象的「圣像骑士」卡
	if chk==0 then return Duel.IsExistingTarget(c54525057.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「圣像骑士」卡作为效果的对象
	local g=Duel.SelectTarget(tp,c54525057.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行：将作为对象的卡加入手卡
function c54525057.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个（也是唯一一个）对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
