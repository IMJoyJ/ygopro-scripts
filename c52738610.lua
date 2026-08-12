--影霊衣の舞姫
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方不能对应「影灵衣」仪式魔法卡的发动把魔法·陷阱·怪兽的效果发动，对方不能把自己场上的「影灵衣」仪式怪兽作为效果的对象。
-- ②：这张卡被效果解放的场合，以「影灵衣舞姬」以外的自己的除外状态的1只「影灵衣」怪兽为对象才能发动。那只怪兽加入手卡。
function c52738610.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能对应「影灵衣」仪式魔法卡的发动把魔法·陷阱·怪兽的效果发动，对方不能把自己场上的「影灵衣」仪式怪兽作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c52738610.chainop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能对应「影灵衣」仪式魔法卡的发动把魔法·陷阱·怪兽的效果发动，对方不能把自己场上的「影灵衣」仪式怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c52738610.tgtg)
	-- 设置效果值为aux.tgoval函数，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果解放的场合，以「影灵衣舞姬」以外的自己的除外状态的1只「影灵衣」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,52738610)
	e3:SetCondition(c52738610.thcon)
	e3:SetTarget(c52738610.thtg)
	e3:SetOperation(c52738610.thop)
	c:RegisterEffect(e3)
end
-- 当有连锁发动时，若该效果为「影灵衣」仪式魔法卡的发动，则设置连锁限制条件
function c52738610.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0xb4) and re:IsActiveType(TYPE_RITUAL) then
		-- 设置连锁限制函数为c52738610.chainlm，仅允许发动者自身进行连锁
		Duel.SetChainLimit(c52738610.chainlm)
	end
end
-- 连锁限制函数，返回值为true表示允许连锁，false表示禁止连锁
function c52738610.chainlm(e,rp,tp)
	return tp==rp
end
-- 目标过滤函数，用于判断是否为「影灵衣」仪式怪兽
function c52738610.tgtg(e,c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_RITUAL)
end
-- 条件函数，判断该效果是否由效果解放触发
function c52738610.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 检索过滤函数，用于筛选除外状态的「影灵衣」怪兽
function c52738610.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and not c:IsCode(52738610) and c:IsAbleToHand()
end
-- 设置选择目标阶段，选择符合条件的除外状态的「影灵衣」怪兽
function c52738610.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c52738610.thfilter(chkc) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c52738610.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的除外状态的「影灵衣」怪兽作为目标
	local g=Duel.SelectTarget(tp,c52738610.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，将目标怪兽加入手牌并确认其存在
function c52738610.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认目标怪兽的存在
		Duel.ConfirmCards(1-tp,tc)
	end
end
