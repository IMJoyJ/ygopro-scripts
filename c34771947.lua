--ラビリンス・ウォール・シャドウ
-- 效果：
-- ①：除原本等级是5星以上的怪兽外的召唤·反转召唤·特殊召唤的怪兽在那个回合不能攻击。
-- ②：1回合1次，自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：对方战斗阶段开始时，以对方场上1只攻击力未满1600的怪兽为对象才能发动。那只怪兽破坏。
function c34771947.initial_effect(c)
	-- 记录该卡可以检索的卡片代码列表
	aux.AddCodeList(c,25955164,62340868,98434877)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 除原本等级是5星以上的怪兽外的召唤·反转召唤·特殊召唤的怪兽在那个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c34771947.target)
	c:RegisterEffect(e2)
	-- 1回合1次，自己主要阶段才能发动。选自己的手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」的其中1只当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34771947,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c34771947.tftg)
	e3:SetOperation(c34771947.tfop)
	c:RegisterEffect(e3)
	-- 对方战斗阶段开始时，以对方场上1只攻击力未满1600的怪兽为对象才能发动。那只怪兽破坏。
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
-- 判断目标怪兽是否在本回合召唤/反转召唤/特殊召唤且原本等级小于5
function c34771947.target(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN) and c:GetOriginalLevel()<5
end
-- 过滤函数，检查手卡·卡组·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」是否满足条件
function c34771947.tffilter(c,tp)
	return c:IsFaceupEx() and c:IsCode(25955164,62340868,98434877)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 判断是否满足发动条件：魔法与陷阱区域有空位且存在符合条件的卡片
function c34771947.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否存在符合条件的卡片
		and Duel.IsExistingMatchingCard(c34771947.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,nil,tp) end
end
-- 处理效果发动，选择并移动卡片到魔法与陷阱区域并改变其类型为永续魔法
function c34771947.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断魔法与陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,c34771947.tffilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 将选中的卡片移动到魔法与陷阱区域
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 将卡片类型改为永续魔法卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否为对方回合开始
function c34771947.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，检查对方场上攻击力小于1600的怪兽
function c34771947.desfilter(c)
	return c:GetAttack()<1600 and c:IsFaceup()
end
-- 设置效果目标，选择对方场上攻击力小于1600的怪兽
function c34771947.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c34771947.desfilter(chkc) end
	-- 判断是否存在符合条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(c34771947.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上攻击力小于1600的怪兽作为目标
	local g=Duel.SelectTarget(tp,c34771947.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果破坏目标怪兽
function c34771947.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
