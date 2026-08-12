--D-HERO ドゥームガイ
-- 效果：
-- 这张卡被战斗破坏送去墓地的场合，下次自己回合的准备阶段时，自己墓地存在的「命运英雄 破灭人」以外的1只名字带有「命运英雄」的怪兽在自己场上特殊召唤。
function c80744121.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c80744121.regop)
	c:RegisterEffect(e1)
end
-- 在自身被战斗破坏送去墓地时，注册一个在下次自己回合准备阶段发动的延迟触发效果
function c80744121.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) then
		-- 下次自己回合的准备阶段时，自己墓地存在的「命运英雄 破灭人」以外的1只名字带有「命运英雄」的怪兽在自己场上特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(80744121,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(c80744121.spcon)
		e1:SetTarget(c80744121.sptg)
		e1:SetOperation(c80744121.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,1)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件判定函数
function c80744121.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己（即“自己回合”）
	return Duel.GetTurnPlayer()==tp
end
-- 过滤出自己墓地中「命运英雄 破灭人」以外的名字带有「命运英雄」且可以特殊召唤的怪兽
function c80744121.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and not c:IsCode(80744121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（选择目标）函数，此效果为强制发动
function c80744121.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c80744121.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只符合条件的「命运英雄」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c80744121.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的实际处理（特殊召唤）函数
function c80744121.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为特殊召唤对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
