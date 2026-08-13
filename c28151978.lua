--SRドミノバタフライ
-- 效果：
-- ←8 【灵摆】 8→
-- 「疾行机人 多米诺蝴蝶」的②的灵摆效果1回合只能使用1次。
-- ①：自己不是风属性怪兽不能灵摆召唤。这个效果不会被无效化。
-- ②：从手卡丢弃1只风属性怪兽，以除外的1只自己的风属性怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- 把这张卡作为同调素材的场合，不是龙族·机械族的风属性怪兽的同调召唤不能使用。从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
function c28151978.initial_effect(c)
	-- 为这张卡附加灵摆怪兽属性，使其可以作为灵摆卡发动、进行灵摆召唤并拥有灵摆刻度。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是风属性怪兽不能灵摆召唤。这个效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c28151978.splimit)
	c:RegisterEffect(e1)
	-- 「疾行机人 多米诺蝴蝶」的②的灵摆效果1回合只能使用1次。②：从手卡丢弃1只风属性怪兽，以除外的1只自己的风属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28151978,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,28151978)
	e2:SetCost(c28151978.thcost)
	e2:SetTarget(c28151978.thtg)
	e2:SetOperation(c28151978.thop)
	c:RegisterEffect(e2)
	-- 把这张卡作为同调素材的场合，不是龙族·机械族的风属性怪兽的同调召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetValue(c28151978.synlimit)
	c:RegisterEffect(e3)
	-- 从额外卡组特殊召唤的这张卡被同调召唤使用的场合除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e4:SetValue(LOCATION_REMOVED)
	e4:SetCondition(c28151978.rmcon)
	c:RegisterEffect(e4)
end
-- 判定灵摆召唤的怪兽是否不是风属性：若被召唤怪兽不是风属性且此次召唤为灵摆召唤，则禁止该特殊召唤，从而实现非风属性怪兽不能灵摆召唤的限制。
function c28151978.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsAttribute(ATTRIBUTE_WIND) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判定手卡中的怪兽是否满足丢弃代价条件：风属性且可以被丢弃。
function c28151978.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDiscardable()
end
-- 执行②效果的丢弃代价：若为发动确认（chk==0）则检查手卡是否有1张可丢弃的风属性怪兽；存在则选择并丢弃1张风属性怪兽作为发动代价。
function c28151978.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认发动代价是否满足：检查自己手卡是否存在至少1张满足风属性且可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c28151978.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡中选择1张风属性怪兽丢弃去墓地，作为效果的发动代价。
	Duel.DiscardHand(tp,c28151978.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索对象卡的筛选条件：对象必须是表侧表示、风属性、怪兽且能够加入手卡。
function c28151978.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动目标判定与选择：确认能否选取除外的1只自己的风属性怪兽为对象；若可，提示玩家选择一张符合条件的卡并设为对象，同时设置返回手卡的操作信息。
function c28151978.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c28151978.thfilter(chkc) end
	-- 确认是否存在至少1张可选取为对象的除外风属性怪兽，即能否满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(c28151978.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择提示，提示文字为‘请选择要加入手牌的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己除外区的风属性怪兽中选择1张作为效果对象，并将其标记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28151978.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记本次操作将把对象卡加入手卡（CATEGORY_TOHAND），用于后续效果交互检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时，取得对象卡，若对象仍与该效果关联，则将其加入持有者的手卡。
function c28151978.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这次发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果处理的原因将对象怪兽从除外区加入持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判定该卡能否作为同调素材：若非风属性或非龙族/机械族，则不能用作同调素材，从而限制只能用于龙族·机械族的风属性怪兽的同调召唤。
function c28151978.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WIND) or not c:IsRace(RACE_DRAGON+RACE_MACHINE)
end
-- 满足‘从额外卡组特殊召唤的这张卡被同调召唤使用’的条件：这张卡是从额外卡组特殊召唤的，并且其被使用的原因为同调素材（REASON_MATERIAL+REASON_SYNCHRO）。
function c28151978.rmcon(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA)
		and bit.band(c:GetReason(),REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
