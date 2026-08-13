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
	-- 这张卡从手卡的特殊召唤成功时，选择对方场上1张魔法·陷阱卡回到持有者手卡。
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
-- 过滤函数：判断怪兽是否为表侧表示且为超量怪兽。
function c15458892.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 特殊召唤规则的处理条件：我方主要怪兽区有空位，并且对方场上有表侧表示的超量怪兽，满足时这张卡可以从手卡特殊召唤。
function c15458892.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否存在至少1个可用区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1张表侧表示的超量怪兽（过滤条件见cfilter）。
		and Duel.IsExistingMatchingCard(c15458892.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 诱发效果的发劥条件：这张卡是从手卡特殊召唤成功的（即特殊召唤前存在于手卡）。
function c15458892.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 选择对象时的过滤条件：对方场上的魔法·陷阱卡，且能够加入手卡。
function c15458892.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 指定效果对象：选择对方场上1张符合条件的魔法·陷阱卡，并设置相应的回手牌操作信息。
function c15458892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c15458892.thfilter(chkc) end
	if chk==0 then return true end
	-- 向操作者显示选择提示：“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动者从对方场上选择1张魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c15458892.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的处理信息：将所选择的对象卡加入手牌（CATEGORY_TOHAND），数量为选中卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将效果对象卡返回持有者手卡。
function c15458892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将对象卡送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
