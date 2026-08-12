--XX－セイバー レイジグラ
-- 效果：
-- ①：这张卡召唤·特殊召唤时，以自己墓地1只「X-剑士」怪兽为对象才能发动。那只怪兽加入手卡。
function c87292536.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤时，以自己墓地1只「X-剑士」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87292536,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(c87292536.target)
	e1:SetOperation(c87292536.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中可以加入手卡的「X-剑士」怪兽
function c87292536.filter(c)
	return c:IsSetCard(0x100d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数
function c87292536.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c87292536.filter(chkc) end
	-- 在发动阶段，检测自己墓地是否存在至少1只满足条件的「X-剑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c87292536.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的「X-剑士」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c87292536.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示将选择的对象卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行函数
function c87292536.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
