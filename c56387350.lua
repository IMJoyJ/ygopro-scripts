--ヴァンパイア・ベビー
-- 效果：
-- 这张卡战斗破坏怪兽的战斗阶段结束时，可以把墓地存在的那些怪兽在自己场上特殊召唤。
function c56387350.initial_effect(c)
	-- 这张卡战斗破坏怪兽的战斗阶段结束时，可以把墓地存在的那些怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56387350,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c56387350.spcon)
	e1:SetTarget(c56387350.sptg)
	e1:SetOperation(c56387350.spop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c56387350.regop)
	c:RegisterEffect(e2)
end
-- 在自身战斗破坏怪兽时，给自身注册一个在战斗阶段结束前有效的Flag，用于记录战斗破坏怪兽的事实
function c56387350.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(56387350,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 检查自身是否带有战斗破坏怪兽的Flag，作为效果发动的条件
function c56387350.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(56387350)~=0
end
-- 过滤出本回合被这张卡战斗破坏并送去墓地，且可以特殊召唤的怪兽
function c56387350.filter(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与目标检测
function c56387350.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只被这张卡战斗破坏的怪兽
		and Duel.IsExistingMatchingCard(c56387350.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 获取双方墓地中所有被这张卡战斗破坏的怪兽
	local g=Duel.GetMatchingGroup(c56387350.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 设置连锁信息，表明此效果包含特殊召唤墓地怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理逻辑
function c56387350.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取墓地中满足条件且不受「王家之谷」影响的被破坏怪兽
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c56387350.filter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
