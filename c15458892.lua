--スターシップ・スパイ・プレーン
-- 效果：
-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。此外，这张卡从手卡的特殊召唤成功时，选择对方场上1张魔法·陷阱卡回到持有者手卡。
function c15458892.initial_effect(c)
	-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15458892.spcon)
	c:RegisterEffect(e1)
	-- 此外，这张卡从手卡的特殊召唤成功时，选择对方场上1张魔法·陷阱卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15458892,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c15458892.thcon)
	e2:SetTarget(c15458892.thtg)
	e2:SetOperation(c15458892.thop)
	c:RegisterEffect(e2)
end
-- 检查目标怪兽是否为超量怪兽且表侧表示
function c15458892.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 判断是否满足特殊召唤条件：有空场地且对方场上存在超量怪兽
function c15458892.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方场上是否存在至少1只超量怪兽
		and Duel.IsExistingMatchingCard(c15458892.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 判断此卡是否由手卡特殊召唤成功
function c15458892.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤出可以送回手牌的魔法·陷阱卡
function c15458892.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置选择目标时的提示信息并选择对方场上的魔法·陷阱卡
function c15458892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c15458892.thfilter(chkc) end
	if chk==0 then return true end
	-- 向玩家发送提示信息“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张满足条件的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c15458892.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，指定将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行效果处理，将选定的魔法·陷阱卡送回对方手牌
function c15458892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选定的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
