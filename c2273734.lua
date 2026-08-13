--星因士 アルタイル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合，以「星因士 河鼓二」以外的自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时「星骑士」怪兽以外的自己怪兽不能攻击。
function c2273734.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤的场合，以「星因士 河鼓二」以外的自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2273734,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,2273734)
	e1:SetTarget(c2273734.sptg)
	e1:SetOperation(c2273734.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c2273734.star_knight_summon_effect=e1
end
-- 筛选墓地中符合条件的对象：必须为「星骑士」怪兽，不能是「星因士 河鼓二」自身，并且能以表侧守备表示被特殊召唤。
function c2273734.filter(c,e,tp)
	return c:IsSetCard(0x9c) and not c:IsCode(2273734) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 对象选择与发动条件判定：若为连锁指定对象则验证该对象是否满足条件；若为发动判定则确认自己场上有空位且墓地存在1只符合条件的「星骑士」怪兽。
function c2273734.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2273734.filter(chkc,e,tp) end
	-- 发动条件检查：自己场上主要怪兽区必须存在可用的空格，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地存在1只不是「星因士 河鼓二」的「星骑士」怪兽，且该怪兽可以作为效果对象并被特殊召唤。
		and Duel.IsExistingTarget(c2273734.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，用于从墓地选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「星骑士」怪兽作为对象，并将其锁定为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c2273734.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将进行1只怪兽的特殊召唤，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽（若仍与效果关联）以表侧守备表示特殊召唤；并给己方场上所有非「星骑士」怪兽附加直到回合结束不能攻击的限制。
function c2273734.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个效果的发动后，直到回合结束时「星骑士」怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c2273734.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把“不能攻击”的限制效果注册到决斗中，使其持续作用于己方场上符合条件的怪兽直到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 判定怪兽是否不属于「星骑士」系列；若是非「星骑士」怪兽，则受到不能攻击的限制。
function c2273734.atktg(e,c)
	return not c:IsSetCard(0x9c)
end
