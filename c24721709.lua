--救魔の標
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只魔法师族效果怪兽为对象才能发动。那只怪兽加入手卡。
function c24721709.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,24721709+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c24721709.target)
	e1:SetOperation(c24721709.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：定义过滤器，用于检索满足条件的卡片组，即魔法师族、效果怪兽且可以加入手卡的墓地怪兽。
function c24721709.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 效果作用：设置效果的目标选择函数，用于选择满足条件的墓地怪兽作为对象。
function c24721709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c24721709.filter(chkc) end
	-- 效果作用：判断是否满足发动条件，即自己墓地是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c24721709.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：向玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的墓地怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c24721709.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置当前连锁的操作信息，指定将要处理的效果分类为回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果原文内容：①：以自己墓地1只魔法师族效果怪兽为对象才能发动。那只怪兽加入手卡。
function c24721709.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽以效果原因加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
