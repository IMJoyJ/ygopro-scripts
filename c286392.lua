--ジェット・ウォリアー
-- 效果：
-- 「喷气同调士」＋调整以外的怪兽1只以上
-- 「喷气战士」的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：这张卡在墓地存在的场合，把自己场上1只2星以下的怪兽解放才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c286392.initial_effect(c)
	-- 为怪兽添加同调召唤所需的素材代码列表，允许使用代码为9742784的卡作为素材
	aux.AddMaterialCodeList(c,9742784)
	-- 设置该怪兽的同调召唤手续，要求1只满足tfilter条件的调整和1只满足aux.NonTuner(nil)条件的调整以外的怪兽
	aux.AddSynchroProcedure(c,c286392.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,286392)
	e1:SetCondition(c286392.thcon)
	e1:SetTarget(c286392.thtg)
	e1:SetOperation(c286392.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己场上1只2星以下的怪兽解放才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,286393)
	e2:SetCost(c286392.spcost)
	e2:SetTarget(c286392.sptg)
	e2:SetOperation(c286392.spop)
	c:RegisterEffect(e2)
end
c286392.material_setcode=0x1017
-- 过滤函数，判断怪兽是否为喷气同调士或具有特定效果（代码20932152）
function c286392.tfilter(c)
	return c:IsCode(9742784) or c:IsHasEffect(20932152)
end
-- 判断效果是否在同调召唤成功时发动
function c286392.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果的目标选择函数，选择对方场上的1张可送回手牌的卡
function c286392.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的对方场上1张卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，指定将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，将目标卡送回持有者手牌
function c286392.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数，判断场上是否可以解放的2星以下怪兽
function c286392.cfilter(c,ft,tp)
	return c:IsLevelBelow(2)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 设置效果的解放费用，需要解放1只2星以下的怪兽
function c286392.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足解放费用条件
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c286392.cfilter,1,nil,ft,tp) end
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c286392.cfilter,1,1,nil,ft,tp)
	-- 以效果原因解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置效果的特殊召唤目标，检查该卡是否可以特殊召唤
function c286392.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果操作信息，指定将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将该卡从墓地特殊召唤到场上
function c286392.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否可以成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 设置特殊召唤后该卡离开场上的处理，将其移除
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
