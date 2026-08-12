--超重剣聖ムサ－C
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡同调召唤成功时，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。自己墓地有魔法·陷阱卡存在的场合，这个回合自己不能把那只怪兽以及那些同名怪兽召唤·特殊召唤。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
function c75988594.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以自己墓地1只机械族怪兽为对象才能发动。那只怪兽加入手卡。自己墓地有魔法·陷阱卡存在的场合，这个回合自己不能把那只怪兽以及那些同名怪兽召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75988594,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c75988594.thcon)
	e2:SetTarget(c75988594.thtg)
	e2:SetOperation(c75988594.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判断是否为同调召唤成功
function c75988594.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：墓地的机械族怪兽且能加入手卡
function c75988594.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果1（加入手卡）的发动准备与目标选择
function c75988594.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c75988594.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c75988594.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75988594.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果1（加入手卡）的效果处理：将目标怪兽加入手牌，若墓地有魔陷则施加召唤限制
function c75988594.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 检查自己墓地是否存在魔法·陷阱卡
		if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP) then
			-- 自己墓地有魔法·陷阱卡存在的场合，这个回合自己不能把那只怪兽以及那些同名怪兽召唤·特殊召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(c75988594.sumlimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册限制召唤同名怪兽的玩家效果
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			-- 注册限制特殊召唤同名怪兽的玩家效果
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 限制召唤/特殊召唤的卡片判定：卡名与被回收的怪兽相同
function c75988594.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
