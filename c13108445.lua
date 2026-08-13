--ジェムナイト・アクアマリナ
-- 效果：
-- 「宝石骑士·青玉」＋「宝石骑士」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：这张卡攻击的场合，战斗阶段结束时变成守备表示。
-- ②：这张卡从场上送去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡回到手卡。
function c13108445.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤素材条件：需要1只卡号27126980的『宝石骑士·青玉』和1只『宝石骑士』系列（0x1047）怪兽作为融合素材，用于该卡的融合召唤。
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
-- 特殊召唤限制判定：当此卡位于额外卡组时，召唤类型必须为融合召唤才允许特殊召唤；若不在额外卡组，则此限制不生效。
function c13108445.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- ②效果的发动条件：此卡从场上被送去墓地时才满足触发条件。
function c13108445.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果的目标处理：当有指定对象需要校验时，检查其是否为对方场上且能加入手卡；当效果发动检测时返回可发动；随后显示选择提示，从对方场上选择1张可加入手卡的卡作为对象，并登记回手牌操作信息。
function c13108445.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 给当前玩家显示“请选择要返回手牌的卡”的提示，用于后续选择对象的界面信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1张可以返回手牌的卡作为效果对象（该卡可以是怪兽·魔法·陷阱）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁的处理信息：效果类别为回手牌，目标为所选择的卡g，数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果处理：获取对象卡；若对象仍与该效果关联，则将其返回持有者手卡。
function c13108445.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象卡（由于只选1张，取第一张即唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送回持有者的手卡，实现“那张对方的卡回到手卡”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ①效果的发动条件：这张卡本回合进行过攻击（攻击次数大于0），在战斗阶段结束时触发。
function c13108445.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- ①效果处理：若这张卡当前是攻击表示，则将其变为表侧守备表示。
function c13108445.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式改为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
