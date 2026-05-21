--ガガガキッド
-- 效果：
-- 自己场上有「我我我小子」以外的名字带有「我我我」的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，可以选择自己场上1只名字带有「我我我」的怪兽，这张卡的等级变成和选择的怪兽相同等级。这个效果发动的回合，自己不能进行战斗阶段。
function c94203886.initial_effect(c)
	-- 自己场上有「我我我小子」以外的名字带有「我我我」的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94203886.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，可以选择自己场上1只名字带有「我我我」的怪兽，这张卡的等级变成和选择的怪兽相同等级。这个效果发动的回合，自己不能进行战斗阶段。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94203886,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c94203886.lvcon)
	e2:SetCost(c94203886.lvcost)
	e2:SetTarget(c94203886.lvtg)
	e2:SetOperation(c94203886.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「我我我小子」以外的「我我我」怪兽
function c94203886.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x54) and not c:IsCode(94203886)
end
-- 特殊召唤规则的条件：自己场上有空位且存在「我我我小子」以外的「我我我」怪兽
function c94203886.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
		Duel.IsExistingMatchingCard(c94203886.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 效果发动条件：这张卡通过自身效果特殊召唤成功
function c94203886.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 效果发动代价：在主要阶段1发动，并给玩家注册本回合不能进行战斗阶段的效果
function c94203886.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否为主要阶段1（因为不能进行战斗阶段，所以必须在主要阶段1发动）
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 这个效果发动的回合，自己不能进行战斗阶段。这个方法特殊召唤成功时，可以选择自己场上1只名字带有「我我我」的怪兽，这张卡的等级变成和选择的怪兽相同等级。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册本回合不能进行战斗阶段的效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：自己场上表侧表示、等级在1以上且与自身当前等级不同的「我我我」怪兽
function c94203886.lvfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x54) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 效果的目标：选择自己场上1只满足过滤条件的「我我我」怪兽作为对象
function c94203886.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94203886.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 检查自己场上是否存在可作为对象的、等级与自身不同的「我我我」怪兽
	if chk==0 then return Duel.IsExistingTarget(c94203886.lvfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择并确认1只满足过滤条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c94203886.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- 效果的处理：使这张卡的等级变成与选择的对象怪兽相同等级
function c94203886.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的等级变成和选择的怪兽相同等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
