--魔弾の射手 ドクトル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。从自己墓地选和那张发动的卡卡名不同的1张「魔弹」卡加入手卡。
function c68246154.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己·对方回合自己可以把「魔弹」魔法·陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68246154,1))  --"适用「魔弹射手 医生」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	-- 设置手卡发动的适用对象为「魔弹」卡片
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x108))
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetValue(32841045)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	-- ②：和这张卡相同纵列有魔法·陷阱卡发动的场合才能发动。从自己墓地选和那张发动的卡卡名不同的1张「魔弹」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68246154,0))  --"墓地回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,68246154)
	e3:SetCondition(c68246154.thcon)
	e3:SetTarget(c68246154.thtg)
	e3:SetOperation(c68246154.thop)
	c:RegisterEffect(e3)
end
-- 判断发动的效果是否为魔法·陷阱卡的发动，且该卡与自身处于相同纵列
function c68246154.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetColumnGroup():IsContains(re:GetHandler())
end
-- 过滤墓地中与发动的卡卡名不同且可以加入手牌的「魔弹」卡
function c68246154.thfilter(c,rc)
	return c:IsSetCard(0x108) and not c:IsCode(rc:GetCode()) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c68246154.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 在发动时检查墓地中是否存在至少1张满足条件的「魔弹」卡
	if chk==0 then return rc and Duel.IsExistingMatchingCard(c68246154.thfilter,tp,LOCATION_GRAVE,0,1,nil,rc) end
	e:SetLabelObject(rc)
	-- 设置将墓地的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：从自己墓地选择1张满足条件的「魔弹」卡加入手牌并给对方确认
function c68246154.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1张不受王家长眠之谷影响且与发动的卡卡名不同的「魔弹」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c68246154.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,e:GetLabelObject())
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
