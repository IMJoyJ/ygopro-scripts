--ジェスター・コンフィ
-- 效果：
-- ①：「糖果小丑」在自己场上只能有1只表侧表示存在。
-- ②：这张卡可以从手卡攻击表示特殊召唤。
-- ③：这张卡的②的方法特殊召唤的场合，下次的对方结束阶段以对方场上1只表侧表示怪兽为对象发动。那只对方的表侧表示怪兽和表侧表示的这张卡回到持有者手卡。
function c8487449.initial_effect(c)
	c:SetUniqueOnField(1,0,8487449)
	-- ②：这张卡可以从手卡攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c8487449.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ③：这张卡的②的方法特殊召唤的场合，下次的对方结束阶段以对方场上1只表侧表示怪兽为对象发动。那只对方的表侧表示怪兽和表侧表示的这张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c8487449.regcon)
	e2:SetOperation(c8487449.regop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件函数：判断自身控制者的怪兽区域是否有空位
function c8487449.spcon(e,c)
	if c==nil then return true end
	-- 判断自身控制者的怪兽区域可用空格数是否大于0
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断是否是通过自身效果（②的方法）特殊召唤成功
function c8487449.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 注册一个在下次对方结束阶段发动的强制诱发效果，用于将自身和对方怪兽送回手牌
function c8487449.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡的②的方法特殊召唤的场合，下次的对方结束阶段以对方场上1只表侧表示怪兽为对象发动。那只对方的表侧表示怪兽和表侧表示的这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8487449,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c8487449.thcon)
	e1:SetTarget(c8487449.thtg)
	e1:SetOperation(c8487449.thop)
	e1:SetReset(RESET_EVENT+0x16a0000+RESET_PHASE+PHASE_END,2)
	-- 将当前回合数记录在效果的Label中，用于后续判断是否为“下次的对方结束阶段”
	e1:SetLabel(Duel.GetTurnCount())
	c:RegisterEffect(e1)
end
-- 判断当前回合数是否为记录的回合数加1（即下个回合，因为是自身回合特召，下个回合即为对方回合）
function c8487449.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否为特召时的回合数加1
	return Duel.GetTurnCount()==e:GetLabel()+1
end
-- 过滤场上表侧表示且可以回到手牌的怪兽
function c8487449.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果发动的目标选择与处理信息设置：选择对方场上1只表侧表示怪兽作为对象，并设置将该怪兽和自身送回手牌的操作信息
function c8487449.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local sp=c:GetSummonPlayer()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-sp) and c8487449.filter(chkc) and chkc~=c end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c8487449.filter,sp,0,LOCATION_MZONE,1,1,c)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 设置效果处理信息：将选中的怪兽和自身（共2张卡）送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
	end
end
-- 效果运行处理：若自身和目标怪兽均在场上表侧表示存在且与效果相关联，则将它们一同送回持有者手牌
function c8487449.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将包含自身和目标怪兽的卡片组送回持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
