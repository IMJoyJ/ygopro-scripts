--ラビリンス・ウォール・シャドウ
-- 效果：
-- ①：除原本等级是5星以上的怪兽外的召唤·反转召唤·特殊召唤的怪兽在那个回合不能攻击。
-- ②：1回合1次，自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：对方战斗阶段开始时，以对方场上1只攻击力未满1600的怪兽为对象才能发动。那只怪兽破坏。
function c34771947.initial_effect(c)
	-- 注册这张卡上记载的卡名代码，使「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」被识别为这张卡提到的卡。
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：除原本等级是5星以上的怪兽外的召唤·反转召唤·特殊召唤的怪兽在那个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c34771947.target)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34771947,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c34771947.tftg)
	e3:SetOperation(c34771947.tfop)
	c:RegisterEffect(e3)
	-- ③：对方战斗阶段开始时，以对方场上1只攻击力未满1600的怪兽为对象才能发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34771947,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c34771947.descon)
	e4:SetTarget(c34771947.destg)
	e4:SetOperation(c34771947.desop)
	c:RegisterEffect(e4)
end
-- 效果①的筛选条件：怪兽在本回合被召唤、反转召唤或特殊召唤，且原本等级小于5星（即不是原本等级5星以上的怪兽）。
function c34771947.target(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN) and c:GetOriginalLevel()<5
end
-- 筛选符合条件的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」：必须是表侧表示，且不是禁止卡，并满足场上同名卡唯一限制。
function c34771947.tffilter(c,tp)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果②的发动条件：自己的魔法与陷阱区域有空位，并且从手卡、卡组或除外区存在至少1张符合条件的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」。
function c34771947.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡、卡组、除外区是否存在至少1张满足tffilter过滤条件的卡。
		and Duel.IsExistingMatchingCard(c34771947.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,nil,tp) end
end
-- 效果②的发动处理：从手卡、卡组或除外区选择1张符合条件的卡，将其以表侧表示放置到自己的魔法与陷阱区域，并使其变为永续魔法卡。
function c34771947.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认魔陷区仍有空格，若无空格则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家显示“请选择要放置到场上的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡、卡组或除外区中选择1张满足tffilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c34771947.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 如果成功选择了卡且移动到自己的魔陷区（表侧表示），则执行后续赋予永续魔法卡种类的处理。
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- “当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置”——将放置的卡种类改变为永续魔法卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：验证当前回合是否为对方回合，即对方战斗阶段开始时。
function c34771947.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为对方玩家，用于限定只能在对方战斗阶段开始时发动。
	return Duel.GetTurnPlayer()==1-tp
end
-- 破坏对象筛选：对方场上表侧表示且攻击力未满1600的怪兽。
function c34771947.desfilter(c)
	return c:GetAttack()<1600 and c:IsFaceup()
end
-- 效果③的目标处理：以对方场上1只攻击力未满1600的表侧表示怪兽为对象，并设置破坏的操作信息。
function c34771947.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c34771947.desfilter(chkc) end
	-- 判定是否存在至少1只满足条件的怪兽可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c34771947.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只攻击力未满1600的表侧表示怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c34771947.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：确定将破坏1张卡，供相关卡片（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的处理：取得对象怪兽，若其仍与本次效果相关（未被其他处理移动或离场），将其破坏。
function c34771947.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
