--ジェット・ウォリアー
-- 效果：
-- 「喷气同调士」＋调整以外的怪兽1只以上
-- 「喷气战士」的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：这张卡在墓地存在的场合，把自己场上1只2星以下的怪兽解放才能发动。这张卡从墓地守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c286392.initial_effect(c)
	-- 声明「喷气战士」的同调素材列表中包含「喷气同调士」(9742784)，使同调召唤手续能识别该卡名。
	aux.AddMaterialCodeList(c,9742784)
	-- 为「喷气战士」添加同调召唤手续：调整必须为「喷气同调士」或其替代素材（c286392.tfilter），调整以外的怪兽任意1只以上。
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
	-- ②：这张卡在墓地存在的场合，把自己场上1只2星以下的怪兽解放才能发动。这张卡从墓地守备表示特殊召唤。
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
-- 素材过滤函数：满足条件的调整是卡号9742784的「喷气同调士」，或拥有卡号20932152所代表的效果（可作为「喷气同调士」替代素材的调整）。
function c286392.tfilter(c)
	return c:IsCode(9742784) or c:IsHasEffect(20932152)
end
-- ①效果的发动条件：这张卡同调召唤成功且召唤类型为同调召唤时才能发动。
function c286392.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的发动选择：以对方场上1张能返回手牌且可作为对象的卡为对象，并设置返回手牌的操作信息。
function c286392.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 发动时检查是否存在至少1张对方场上满足「能返回手牌」且可作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1张满足条件的卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将当前连锁的操作信息设置为：将1张对象卡返回持有者手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得对象卡，若该卡仍与效果关联则将其返回持有者手卡。
function c286392.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 解放素材过滤函数：要求等级2以下；若自己主怪兽区没有空格，则必须选择自己主怪兽区的怪兽；若选择对方怪兽则必须表侧表示。
function c286392.cfilter(c,ft,tp)
	return c:IsLevelBelow(2)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- ②效果的代价处理：检查能否解放1只满足条件的怪兽，并选择后解放作为发动代价。
function c286392.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区的可用空格数，用于判断解放后是否有格子可以特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 代价检查：可用空格数需大于-1（解放后至少留1个空格），且存在可解放的满足条件的怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c286392.cfilter,1,nil,ft,tp) end
	-- 选择1只满足条件的怪兽作为②效果的解放代价。
	local g=Duel.SelectReleaseGroup(tp,c286392.cfilter,1,1,nil,ft,tp)
	-- 将选择的怪兽解放，解放原因为代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标检查：确认墓地的这张卡能否以表侧守备表示特殊召唤，并设置特殊召唤的操作信息。
function c286392.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将当前连锁的操作信息设置为：将墓地的这张卡特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其以表侧守备表示特殊召唤；成功后赋予其离场时除外的效果。
function c286392.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果关联，并尝试以表侧守备表示特殊召唤；特殊召唤成功（返回值不等于0）时才附加除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
