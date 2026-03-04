--ジェムナイト・アクアマリナ
-- 效果：
-- 「宝石骑士·青玉」＋「宝石骑士」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡攻击的场合，战斗阶段结束时变成守备表示。
-- ②：这张卡从场上送去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡回到手卡。
function c13108445.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为27126980的怪兽和1个满足种族为宝石骑士的效果的怪兽作为融合素材进行融合召唤
	aux.AddFusionProcCodeFun(c,27126980,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c13108445.splimit)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13108445,0))  --"返回手牌"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c13108445.thcon)
	e3:SetTarget(c13108445.thtg)
	e3:SetOperation(c13108445.thop)
	c:RegisterEffect(e3)
	-- ①：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c13108445.poscon)
	e4:SetOperation(c13108445.posop)
	c:RegisterEffect(e4)
end
-- 判断是否满足特殊召唤条件，只有从额外卡组特殊召唤且为融合召唤时才允许特殊召唤
function c13108445.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 判断该卡是否从场上离开（即被送去墓地）
function c13108445.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置效果目标，选择对方场上1张可送入手牌的卡
function c13108445.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向玩家提示选择要送入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择对方场上1张可送入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定将要处理的卡为1张对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行效果操作，将目标卡送入手牌
function c13108445.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断该卡是否在战斗阶段中攻击过
function c13108445.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 执行效果操作，若该卡在攻击后则将其变为守备表示
function c13108445.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将该卡变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
