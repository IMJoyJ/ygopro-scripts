--影六武衆－ゲンバ
-- 效果：
-- ①：这张卡召唤成功时，以除外的1只自己的「六武众」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c7291576.initial_effect(c)
	-- ①：这张卡召唤成功时，以除外的1只自己的「六武众」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7291576,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c7291576.thtg)
	e1:SetOperation(c7291576.thop)
	c:RegisterEffect(e1)
	-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c7291576.reptg)
	e2:SetValue(c7291576.repval)
	e2:SetOperation(c7291576.repop)
	c:RegisterEffect(e2)
end
-- 过滤除外状态的、表侧表示的、属于「六武众」的怪兽卡，且该卡可以加入手卡
function c7291576.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备，包括判断是否满足发动条件、提示玩家选择对象、将选择的卡作为效果对象并设置操作信息
function c7291576.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c7291576.thfilter(chkc) end
	-- 在效果发动阶段，检测除外区是否存在至少1只满足条件的自己的「六武众」怪兽
	if chk==0 then return Duel.IsExistingTarget(c7291576.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1只除外区的、满足条件的「六武众」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c7291576.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理的操作信息，表示该效果包含将选中的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理，获取选中的对象，若该卡仍符合条件，则将其加入手牌
function c7291576.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的、属于自己且因效果将被破坏的「六武众」怪兽
function c7291576.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动准备，判断墓地的此卡是否可以除外，以及是否刚好只有1只自己的「六武众」怪兽因效果被破坏
function c7291576.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c7291576.repfilter,1,nil,tp)
		and eg:GetCount()==1 end
	-- 询问玩家是否要发动此卡的代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 用于过滤和确认具体是哪一只「六武众」怪兽被代替破坏
function c7291576.repval(e,c)
	return c7291576.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理，将墓地的此卡除外
function c7291576.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
