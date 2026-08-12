--運命の抱く爆弾
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。对方场上1只攻击力最高的怪兽破坏，给与对方那个原本攻击力数值的伤害。自己墓地没有「现世与冥界的逆转」存在的场合，再让自己受到和对方受到的伤害相同数值的伤害。
-- ②：这张卡从手卡·卡组送去墓地的场合，以自己墓地1只天使族·地属性·4星怪兽为对象才能发动。那只怪兽加入手卡。
function c51208877.initial_effect(c)
	-- 注册卡片效果中涉及的其他卡名，此处为「现世与冥界的逆转」
	aux.AddCodeList(c,17484499)
	-- ①：对方怪兽的攻击宣言时才能发动。对方场上1只攻击力最高的怪兽破坏，给与对方那个原本攻击力数值的伤害。自己墓地没有「现世与冥界的逆转」存在的场合，再让自己受到和对方受到的伤害相同数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,51208877)
	e1:SetCondition(c51208877.condition)
	e1:SetTarget(c51208877.target)
	e1:SetOperation(c51208877.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组送去墓地的场合，以自己墓地1只天使族·地属性·4星怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,51208878)
	e2:SetCondition(c51208877.thcon)
	e2:SetTarget(c51208877.thtg)
	e2:SetOperation(c51208877.thop)
	c:RegisterEffect(e2)
end
-- 效果条件：判断是否为对方回合
function c51208877.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前玩家不等于回合玩家时效果才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 设置连锁处理的目标：选择对方场上攻击力最高的怪兽进行破坏
function c51208877.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 设置连锁操作信息：将目标怪兽设为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	local _,dam=tg:GetMaxGroup(Card.GetBaseAttack)
	if dam>0 then
		-- 设置连锁操作信息：对对方造成伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
-- 效果处理函数：执行攻击宣言时的效果处理
function c51208877.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		local dam=0
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 显示选中的卡作为对象
			Duel.HintSelection(sg)
			-- 破坏选中的卡并判断是否成功
			if Duel.Destroy(sg,REASON_EFFECT)>0 then
				dam=sg:GetFirst():GetBaseAttack()
			end
		else
			-- 直接破坏目标怪兽并判断是否成功
			if Duel.Destroy(tg,REASON_EFFECT)>0 then
				dam=tg:GetFirst():GetBaseAttack()
			end
		end
		if dam>0 then
			-- 对对方造成伤害
			Duel.Damage(1-tp,dam,REASON_EFFECT)
			-- 检查自己墓地是否存在「现世与冥界的逆转」
			if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,17484499) then
				-- 若不存在则对自己造成相同数值的伤害
				Duel.Damage(tp,dam,REASON_EFFECT)
			end
		end
	end
end
-- 效果发动条件：确认此卡是从手牌或卡组送去墓地
function c51208877.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 过滤函数：筛选墓地中满足种族、属性、等级要求的怪兽
function c51208877.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 设置连锁处理的目标：选择墓地中符合条件的怪兽加入手牌
function c51208877.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51208877.thfilter(chkc) end
	-- 检查是否有满足条件的墓地怪兽可选
	if chk==0 then return Duel.IsExistingTarget(c51208877.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c51208877.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：执行墓地触发效果
function c51208877.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
