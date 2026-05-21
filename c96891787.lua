--教導の鉄槌テオ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
-- ③：以从额外卡组特殊召唤的场上1只表侧表示怪兽为对象才能发动。直到回合结束时，这张卡的攻击力上升600，作为对象的怪兽的攻击力下降600。
function c96891787.initial_effect(c)
	-- ①：从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96891787,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,96891787)
	e1:SetCondition(c96891787.spcon)
	e1:SetTarget(c96891787.sptg)
	e1:SetOperation(c96891787.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会被和从额外卡组特殊召唤的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c96891787.indes)
	c:RegisterEffect(e2)
	-- ③：以从额外卡组特殊召唤的场上1只表侧表示怪兽为对象才能发动。直到回合结束时，这张卡的攻击力上升600，作为对象的怪兽的攻击力下降600。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96891787,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,96891788)
	e3:SetTarget(c96891787.atktg)
	e3:SetOperation(c96891787.atkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：从额外卡组特殊召唤的怪兽
function c96891787.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果①的发动条件：场上存在从额外卡组特殊召唤的怪兽
function c96891787.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1只从额外卡组特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(c96891787.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息）
function c96891787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（将自身特殊召唤）
function c96891787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 战斗破坏抗性的判定函数：对方怪兽是从额外卡组特殊召唤的怪兽
function c96891787.indes(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤条件：从额外卡组特殊召唤的场上表侧表示怪兽
function c96891787.atkfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
end
-- 效果③的发动准备与对象选择（选择1只从额外卡组特殊召唤的场上表侧表示怪兽为对象）
function c96891787.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c96891787.atkfilter(chkc) end
	-- 检查场上是否存在可以作为效果对象的、从额外卡组特殊召唤的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c96891787.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c96891787.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果③的效果处理（自身攻击力上升600，对象怪兽攻击力下降600）
function c96891787.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到回合结束时，这张卡的攻击力上升600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(600)
		c:RegisterEffect(e1)
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 作为对象的怪兽的攻击力下降600
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetValue(-600)
			tc:RegisterEffect(e2)
		end
	end
end
