--ガード・マンティス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付1000基本分才能发动。这张卡从手卡守备表示特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是昆虫族怪兽不能特殊召唤。
-- ②：对方回合，以自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的表示形式变更。
function c53754104.initial_effect(c)
	-- ①：支付1000基本分才能发动。这张卡从手卡守备表示特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是昆虫族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53754104,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,53754104)
	e1:SetCost(c53754104.spcost)
	e1:SetTarget(c53754104.sptg)
	e1:SetOperation(c53754104.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己场上1只昆虫族怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53754104,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,53754105)
	e2:SetCondition(c53754104.poscon)
	e2:SetTarget(c53754104.postg)
	e2:SetOperation(c53754104.posop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价：检查并支付1000基本分。
function c53754104.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检测能否支付1000基本分（chk==0为发动合法性确认）。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 效果①的发动目标：确认自己主要怪兽区有空位且这张卡可以表侧守备表示特殊召唤，并设定特殊召唤的操作信息。
function c53754104.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检测主要怪兽区有空位，且此卡满足以表侧守备表示特殊召唤的条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设定本次连锁中将要进行特殊召唤的操作信息（对象为此卡，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理时：若此卡仍与效果关联，将其表侧守备表示特殊召唤；成功后为此卡赋予一个永续效果，限制自己只能特殊召唤昆虫族怪兽。
function c53754104.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍在场上且与发动效果关联，然后以表侧守备表示特殊召唤；若特殊召唤成功则继续执行后续自肃效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是昆虫族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c53754104.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 自肃效果的过滤条件：不是昆虫族怪兽的怪兽不能特殊召唤。
function c53754104.splimit(e,c)
	return not c:IsRace(RACE_INSECT)
end
-- 效果②的发动条件：仅在自己回合的对方回合（当前回合玩家不是自己）时才能发动。
function c53754104.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方的回合。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的对象筛选条件：表侧表示、昆虫族、且可以变更表示形式的怪兽。
function c53754104.pfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
		and c:IsCanChangePosition()
end
-- 效果②的发动目标：选择自己场上1只符合条件的昆虫族怪兽为对象，并设定变更表示形式的操作信息。
function c53754104.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53754104.pfilter(chkc) end
	-- 发动时确认自己场上是否存在至少1只满足条件的昆虫族怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c53754104.pfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为‘请选择要改变表示形式的怪兽’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择自己场上1只符合条件的昆虫族怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c53754104.pfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设定本次连锁中将变更表示形式的操作信息，对象为选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果②处理时：取得对象怪兽，若仍与效果关联，则变更其表示形式。
function c53754104.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更对象怪兽的表示形式：表侧攻击与表侧守备互相切换。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
