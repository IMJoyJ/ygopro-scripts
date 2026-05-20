--フォーチュンレディ・ダルキー
-- 效果：
-- 这张卡的攻击力·守备力变成这张卡的等级×400的数值。自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。只要这张卡在自己场上表侧表示存在，自己场上表侧表示存在的名字带有「命运女郎」的怪兽战斗破坏对方怪兽送去墓地时，可以选择自己墓地存在的1只名字带有「命运女郎」的怪兽特殊召唤。
function c55586621.initial_effect(c)
	-- 这张卡的攻击力·守备力变成这张卡的等级×400的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c55586621.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- 自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55586621,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c55586621.lvcon)
	e3:SetOperation(c55586621.lvop)
	c:RegisterEffect(e3)
	-- 只要这张卡在自己场上表侧表示存在，自己场上表侧表示存在的名字带有「命运女郎」的怪兽战斗破坏对方怪兽送去墓地时，可以选择自己墓地存在的1只名字带有「命运女郎」的怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55586621,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCondition(c55586621.spcon)
	e4:SetTarget(c55586621.sptg)
	e4:SetOperation(c55586621.spop)
	c:RegisterEffect(e4)
end
-- 计算并返回这张卡的等级×400的数值（用于确定攻击力·守备力）
function c55586621.value(e,c)
	return c:GetLevel()*400
end
-- 等级上升效果的发动条件：当前回合玩家是自己（自己的准备阶段）
function c55586621.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 等级上升效果的处理：若自身表侧表示存在且等级在12以下，则等级上升1星
function c55586621.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 特殊召唤效果的发动条件：自己场上表侧表示的「命运女郎」怪兽战斗破坏对方怪兽并送去墓地
function c55586621.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local rc=tc:GetReasonCard()
	return eg:GetCount()==1 and rc:IsControler(tp) and rc:IsSetCard(0x31)
		and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsLocation(LOCATION_GRAVE)
end
-- 墓地中「命运女郎」怪兽的过滤条件（用于特殊召唤）
function c55586621.spfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向/发动准备：检查怪兽区域空位并选择墓地中1只「命运女郎」怪兽作为对象
function c55586621.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c55586621.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「命运女郎」怪兽
		and Duel.IsExistingTarget(c55586621.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地存在的1只「命运女郎」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55586621.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含特殊召唤所选怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理：将选择的墓地怪兽特殊召唤到场上
function c55586621.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
