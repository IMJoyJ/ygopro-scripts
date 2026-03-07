--サイバー・エンジェル－荼吉尼－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。对方必须把自身场上1只怪兽送去墓地。
-- ②：只要这张卡在怪兽区域存在，自己的仪式怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：自己结束阶段以自己墓地1只仪式怪兽或者1张「机械天使的仪式」为对象才能发动。那张卡加入手卡。
function c39618799.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合才能发动。对方必须把自身场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39618799,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39618799.tgcon)
	e1:SetTarget(c39618799.tgtg)
	e1:SetOperation(c39618799.tgop)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，自己的仪式怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为所有仪式怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_RITUAL))
	c:RegisterEffect(e2)
	-- ③：自己结束阶段以自己墓地1只仪式怪兽或者1张「机械天使的仪式」为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39618799,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c39618799.thcon)
	e3:SetTarget(c39618799.thtg)
	e3:SetOperation(c39618799.thop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：这张卡是仪式召唤成功
function c39618799.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 设置效果目标：对方场上存在怪兽
function c39618799.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：对方场上存在怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	-- 设置连锁操作信息：将对方场上1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
-- 效果处理：选择对方场上1只怪兽送去墓地
function c39618799.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 提示选择要送去墓地的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 显示选择的怪兽被选为对象
		Duel.HintSelection(sg)
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- 效果发动条件：当前为自己的结束阶段
function c39618799.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：判断是否为仪式怪兽或「机械天使的仪式」
function c39618799.thfilter(c)
	return (c:IsCode(39996157) or bit.band(c:GetType(),0x81)==0x81) and c:IsAbleToHand()
end
-- 设置效果目标：选择墓地中的仪式怪兽或「机械天使的仪式」
function c39618799.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39618799.thfilter(chkc) end
	-- 判断是否满足发动条件：墓地存在仪式怪兽或「机械天使的仪式」
	if chk==0 then return Duel.IsExistingTarget(c39618799.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从墓地选择1张仪式怪兽或「机械天使的仪式」
	local g=Duel.SelectTarget(tp,c39618799.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选择的卡加入手牌
function c39618799.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
