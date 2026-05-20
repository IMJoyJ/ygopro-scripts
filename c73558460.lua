--サイバネット・リカバー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上的连接怪兽被战斗或者对方的效果破坏的场合，以连接怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c73558460.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上的连接怪兽被战斗或者对方的效果破坏的场合，以连接怪兽以外的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73558460,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,73558460)
	e2:SetCondition(c73558460.spcon)
	e2:SetTarget(c73558460.sptg)
	e2:SetOperation(c73558460.spop)
	c:RegisterEffect(e2)
end
-- 过滤被破坏的卡：必须是自己场上原本表侧表示的连接怪兽，且因战斗或对方的效果被破坏
function c73558460.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 发动条件：被破坏的卡中存在满足条件的自己场上的连接怪兽
function c73558460.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c73558460.cfilter,1,nil,tp)
end
-- 过滤目标怪兽：自己墓地中连接怪兽以外且可以特殊召唤的怪兽
function c73558460.filter(c,e,tp)
	return not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的对象选择与合法性检测
function c73558460.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73558460.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为对象的、连接怪兽以外的可特殊召唤怪兽
		and Duel.IsExistingTarget(c73558460.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只连接怪兽以外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73558460.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽以表侧守备表示特殊召唤
function c73558460.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
