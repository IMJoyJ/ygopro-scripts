--ブレイン・クラッシャー
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地的场合，可以使破坏的1只怪兽在那个回合的结束阶段时从墓地特殊召唤到自己场上。这个效果1回合只能使用1次。
function c81919143.initial_effect(c)
	-- 可以使破坏的1只怪兽在那个回合的结束阶段时从墓地特殊召唤到自己场上。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81919143,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c81919143.spcon)
	e1:SetTarget(c81919143.sptg)
	e1:SetOperation(c81919143.spop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c81919143.regop)
	c:RegisterEffect(e2)
end
-- 战斗破坏怪兽送去墓地时，为自身注册一个持续到回合结束阶段的Flag，作为结束阶段发动效果的条件
function c81919143.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(81919143,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否在本回合因战斗破坏过对方怪兽而注册了Flag
function c81919143.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(81919143)~=0
end
-- 过滤出本回合被这张卡战斗破坏送去墓地、且可以特殊召唤的怪兽
function c81919143.filter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 结束阶段特殊召唤效果的发动准备，检查怪兽区域空格并选择目标
function c81919143.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 作为效果对象的目标卡片合法性检查（是否仍在墓地且满足条件）
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c81919143.filter(chkc,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c81919143.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只被此卡战斗破坏的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81919143.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 设置当前连锁的操作信息为特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 结束阶段特殊召唤效果的实际处理，将选择的对象特殊召唤到自己场上
function c81919143.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
