--D-HERO ダイハードガイ
-- 效果：
-- 这张卡在自己场上表侧表示存在时，自己场上除这张卡以外的名字带有「命运英雄」的怪兽被战斗破坏送去墓地的场合，可以把那1只怪兽在下次自己的准备阶段时在自己场上特殊召唤。这个效果1回合只能使用1次。
function c77608643.initial_effect(c)
	-- 这张卡在自己场上表侧表示存在时，自己场上除这张卡以外的名字带有「命运英雄」的怪兽被战斗破坏送去墓地的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c77608643.operation)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
	-- 可以把那1只怪兽在下次自己的准备阶段时在自己场上特殊召唤。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77608643,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c77608643.spcon)
	e2:SetTarget(c77608643.sptg)
	e2:SetOperation(c77608643.spop)
	e2:SetLabelObject(g)
	c:RegisterEffect(e2)
end
-- 过滤满足“被战斗破坏送去自己墓地的「命运英雄」怪兽”条件的卡片
function c77608643.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousControler(tp) and c:IsSetCard(0xc008)
end
-- 收集被战斗破坏的「命运英雄」怪兽，并给自身添加标记以记录该事件
function c77608643.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c77608643.filter,nil,e,tp)
	if g:GetCount()==0 then return end
	local sg=e:GetLabelObject()
	local c=e:GetHandler()
	if c:GetFlagEffect(77608643)==0 then
		sg:Clear()
		c:RegisterFlagEffect(77608643,RESET_EVENT+0x3fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
	sg:Merge(g)
end
-- 检查当前是否为自己的回合，且自身是否带有记录了战斗破坏事件的标记
function c77608643.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是自己，且自身卡片上存在对应的Flag标记
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(77608643)~=0
end
-- 过滤在墓地中、因战斗破坏、且可以被特殊召唤并作为效果对象的卡片
function c77608643.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 效果发动的对象选择与合法性检测，从记录的卡片中选择1只作为效果对象
function c77608643.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabelObject():IsContains(chkc) and c77608643.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetLabelObject():IsExists(c77608643.spfilter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=e:GetLabelObject():FilterSelect(tp,c77608643.spfilter,1,1,nil,e,tp)
	-- 将选择的卡片设置为当前效果的处理对象
	Duel.SetTargetCard(g)
	-- 设置连锁的操作信息，表示该效果包含特殊召唤1只目标卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，将作为对象的怪兽在自己场上特殊召唤
function c77608643.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
