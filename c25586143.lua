--捕食植物キメラフレシア
-- 效果：
-- 「捕食植物」怪兽＋暗属性怪兽
-- ①：1回合1次，以持有这张卡的等级以下的等级的场上1只怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡和对方的表侧表示怪兽进行战斗的攻击宣言时才能发动。直到回合结束时，那只对方怪兽的攻击力下降1000，这张卡的攻击力上升1000。
-- ③：这张卡被送去墓地的场合，下次的准备阶段才能发动。从卡组把1张「融合」魔法卡加入手卡。
function c25586143.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用满足「捕食植物」卡组且暗属性的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10f3),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- ①：1回合1次，以持有这张卡的等级以下的等级的场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25586143,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25586143.rmtg)
	e1:SetOperation(c25586143.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方的表侧表示怪兽进行战斗的攻击宣言时才能发动。直到回合结束时，那只对方怪兽的攻击力下降1000，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25586143,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c25586143.atkcon)
	e2:SetTarget(c25586143.atktg)
	e2:SetOperation(c25586143.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，下次的准备阶段才能发动。从卡组把1张「融合」魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c25586143.regop)
	c:RegisterEffect(e3)
	-- 将卡片效果注册为墓地时触发的效果
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25586143,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(c25586143.thcon)
	e4:SetTarget(c25586143.thtg)
	e4:SetOperation(c25586143.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示、等级不超过指定等级且可以除外
function c25586143.rmfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv) and c:IsAbleToRemove()
end
-- 设置效果目标，选择满足条件的场上怪兽作为除外对象
function c25586143.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25586143.rmfilter(chkc,c:GetLevel()) end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c25586143.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c:GetLevel()) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c25586143.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c:GetLevel())
	-- 设置效果操作信息，表示将要除外怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果操作，将目标怪兽除外
function c25586143.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否满足攻击宣言时发动效果的条件
function c25586143.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup()
end
-- 设置攻击宣言时发动效果的目标
function c25586143.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():CreateEffectRelation(e)
end
-- 执行攻击宣言时发动的效果，使对方怪兽攻击力下降1000，自身攻击力上升1000
function c25586143.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
		-- 使对方怪兽攻击力下降1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() and not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 使自身攻击力上升1000
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(1000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end
-- 注册墓地时的准备阶段触发效果
function c25586143.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 注册标记，用于判断下次准备阶段是否可以发动效果
		e:GetHandler():RegisterFlagEffect(25586143,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(25586143,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1,0)
	end
end
-- 判断是否满足下次准备阶段发动效果的条件
function c25586143.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(25586143)
	-- 判断标记的回合数是否与当前回合数不同
	return tid and tid~=Duel.GetTurnCount()
end
-- 过滤函数，用于判断卡是否为「融合」魔法卡且可以加入手牌
function c25586143.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置检索效果的目标，选择满足条件的魔法卡
function c25586143.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25586143.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，表示将要检索魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作，检索并加入手牌
function c25586143.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c25586143.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
