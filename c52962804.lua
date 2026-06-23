--ドラグニティ・ドラフト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「龙骑兵团」怪兽为对象。那个场合，那只怪兽加入手卡。
-- ②：这张卡在魔法与陷阱区域存在，原本等级是5星以上的自己的「龙骑兵团」怪兽攻击的场合，那只怪兽直到伤害步骤结束时不受对方的效果影响。
function c52962804.initial_effect(c)
	-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「龙骑兵团」怪兽为对象。那个场合，那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,52962804+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c52962804.target)
	c:RegisterEffect(e1)
	-- ②：这张卡在魔法与陷阱区域存在，原本等级是5星以上的自己的「龙骑兵团」怪兽攻击的场合，那只怪兽直到伤害步骤结束时不受对方的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c52962804.immtg)
	e2:SetValue(c52962804.efilter)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地4星以下的龙骑兵团怪兽
function c52962804.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x29) and c:IsAbleToHand()
end
-- 处理发动时选择是否以墓地怪兽为对象的效果
function c52962804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52962804.thfilter(chkc) end
	if chk==0 then return true end
	-- 判断我方墓地是否存在满足条件的怪兽
	if Duel.IsExistingTarget(c52962804.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否选择以墓地怪兽为对象发动效果
		and Duel.SelectYesNo(tp,aux.Stringid(52962804,0)) then  --"是否以自己墓地怪兽为对象发动？"
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c52962804.activate)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择目标墓地的龙骑兵团4星以下怪兽
		local g=Duel.SelectTarget(tp,c52962804.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置连锁操作信息，确定将目标怪兽加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 处理将目标怪兽加入手牌的效果
function c52962804.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断是否为满足条件的龙骑兵团5星以上攻击怪兽
function c52962804.immtg(e,c)
	-- 判断目标怪兽是否为5星以上且为龙骑兵团，且正在攻击
	return c:GetOriginalLevel()>=5 and c:IsSetCard(0x29) and Duel.GetAttacker()==c
end
-- 过滤效果不作用于对方玩家的效果
function c52962804.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
