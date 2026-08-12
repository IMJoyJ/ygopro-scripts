--先史遺産ソル・モノリス
-- 效果：
-- 1回合1次，选择自己场上1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽的等级变成6星。这个效果发动的回合，自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
function c93543806.initial_effect(c)
	-- 1回合1次，选择自己场上1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽的等级变成6星。这个效果发动的回合，自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93543806,0))  --"等级变化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c93543806.lvcost)
	e1:SetTarget(c93543806.lvtg)
	e1:SetOperation(c93543806.lvop)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合玩家特殊召唤非「先史遗产」怪兽的次数
	Duel.AddCustomActivityCounter(93543806,ACTIVITY_SPSUMMON,c93543806.counterfilter)
end
-- 计数器的过滤函数，用于判定特殊召唤的怪兽是否为「先史遗产」怪兽
function c93543806.counterfilter(c)
	return c:IsSetCard(0x70)
end
-- 效果发动的Cost函数，检查本回合是否未特召过非「先史遗产」怪兽，并注册本回合不能特召非「先史遗产」怪兽的誓约效果
function c93543806.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查本回合玩家是否没有特殊召唤过非「先史遗产」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(93543806,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不能把名字带有「先史遗产」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c93543806.splimit)
	-- 给玩家注册不能特殊召唤非「先史遗产」怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，使玩家不能特殊召唤非「先史遗产」怪兽
function c93543806.splimit(e,c)
	return not c:IsSetCard(0x70)
end
-- 过滤自己场上表侧表示、等级不为6且有等级的名字带有「先史遗产」的怪兽
function c93543806.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x70) and not c:IsLevel(6) and c:IsLevelAbove(1)
end
-- 效果的发动目标选择（Target）函数，用于选择自己场上1只表侧表示的「先史遗产」怪兽作为效果对象
function c93543806.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c93543806.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的「先史遗产」怪兽
	if chk==0 then return Duel.IsExistingTarget(c93543806.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「先史遗产」怪兽作为效果对象
	Duel.SelectTarget(tp,c93543806.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果的处理（Operation）函数，使选择的怪兽等级变成6星
function c93543806.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的等级变成6星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(6)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
