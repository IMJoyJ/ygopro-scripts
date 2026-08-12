--サイバー・エンジェル－荼吉尼－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡仪式召唤成功的场合才能发动。对方必须把自身场上1只怪兽送去墓地。
-- ②：只要这张卡在怪兽区域存在，自己的仪式怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：自己结束阶段以自己墓地1只仪式怪兽或者1张「机械天使的仪式」为对象才能发动。那张卡加入手卡。
function c39618799.initial_effect(c)
	-- 注册卡片密码39996157（机械天使的仪式）到本卡的关系卡片列表中
	aux.AddCodeList(c,39996157)
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
	-- ②：只要这张卡在怪兽区域存在，自己的仪式怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置贯穿伤害效果的适用对象为我方的仪式怪兽
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
-- 作为①号效果的条件判定函数，检查本卡是否由仪式召唤方式特殊召唤成功
function c39618799.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- ①号效果的发动靶指向（Target）函数，设置操作分类为送去墓地，并做发动前怪兽数量的检测
function c39618799.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方怪兽区域是否存在卡片，如果不存在则不能发动此效果
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	-- 设置当前连锁的操作信息，将1张对方场上的怪兽送去墓地（非取对象）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
-- ①号效果的执行逻辑（Operation）函数，让对方选择自身场上1只怪兽送去墓地
function c39618799.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家场上所有的怪兽卡
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 向对方玩家发送提示信息：“请选择要送去墓地的卡”
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 为被选择的卡片显示选定动画提示
		Duel.HintSelection(sg)
		-- 对方玩家根据规则将选定的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
-- ③号效果的发动条件判定函数，在自己的回合结束阶段满足条件
function c39618799.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是该卡控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤墓地卡片的函数，检查卡片是否是「机械天使的仪式」（卡号39996157）或仪式怪兽且能够加入手牌
function c39618799.thfilter(c)
	return (c:IsCode(39996157) or bit.band(c:GetType(),0x81)==0x81) and c:IsAbleToHand()
end
-- ③号效果的发动靶指向（Target）函数，选择墓地中的卡作为效果的对象并设置操作信息
function c39618799.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39618799.thfilter(chkc) end
	-- 判断我方墓地是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingTarget(c39618799.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向我方玩家发送提示信息：“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择我方墓地中符合条件的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c39618799.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，将所选的对象卡片加入我方手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③号效果的执行逻辑（Operation）函数，将选定的对象卡片加入手牌
function c39618799.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在Target阶段选取的第1个对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将取对象卡片通过效果加入持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
