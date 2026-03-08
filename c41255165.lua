--ペンギン忍者
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡反转的场合，以对方场上最多2张魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
-- ②：以自己场上1只「企鹅」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c41255165.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上最多2张魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41255165,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetTarget(c41255165.target)
	e1:SetOperation(c41255165.operation)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「企鹅」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41255165,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,41255165)
	e2:SetTarget(c41255165.postg)
	e2:SetOperation(c41255165.posop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的魔法·陷阱卡（可被送入手牌）
function c41255165.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理：选择对方场上的魔法·陷阱卡作为对象
function c41255165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c41255165.thfilter(chkc) end
	-- 确认是否满足选择对象的条件（对方场上存在魔法·陷阱卡）
	if chk==0 then return Duel.IsExistingTarget(c41255165.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1~2张对方场上的魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c41255165.thfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果处理信息：将选中的卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将对象卡送入手牌
function c41255165.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
		-- 将符合条件的卡送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 检索满足条件的「企鹅」怪兽（可变为里侧守备表示）
function c41255165.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5a) and c:IsCanTurnSet()
end
-- 效果处理：选择自己场上的「企鹅」怪兽作为对象
function c41255165.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41255165.filter(chkc) end
	-- 确认是否满足选择对象的条件（自己场上存在「企鹅」怪兽）
	if chk==0 then return Duel.IsExistingTarget(c41255165.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只自己场上的「企鹅」怪兽作为对象
	local g=Duel.SelectTarget(tp,c41255165.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：将对象怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理：将对象怪兽变为里侧守备表示
function c41255165.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将对象怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
