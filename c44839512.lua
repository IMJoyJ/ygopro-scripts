--超電導戦士 リニア・マグナム±
-- 效果：
-- 这张卡不能通常召唤。「超电导战士 线性磁炮王±」1回合1次在从自己的手卡·卡组·场上（表侧表示）把2只原本等级是4星以下的「磁石战士」怪兽送去墓地的场合可以特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只其他的地属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那个攻击力一半数值。
-- ②：这张卡被破坏送去墓地的场合发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤条件、攻击力上升效果、破坏时回到手卡效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：以场上1只其他的地属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那个攻击力一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- 这张卡不能通常召唤。「超电导战士 线性磁炮王±」1回合1次在从自己的手卡·卡组·场上（表侧表示）把2只原本等级是4星以下的「磁石战士」怪兽送去墓地的场合可以特殊召唤。这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的「磁石战士」怪兽：表侧表示、种族为磁石战士、等级小于5、可以送去墓地作为费用
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x2066) and c:GetOriginalLevel()<5 and c:IsAbleToGraveAsCost()
end
-- 判断是否满足特殊召唤条件：获取所有满足条件的怪兽组，检查是否存在2只怪兽的组合能放入怪兽区
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取所有满足条件的怪兽组
	local mg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 检查是否存在2只怪兽的组合能放入怪兽区
	return mg:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 设置特殊召唤目标：选择2只满足条件的怪兽并标记为即将送去墓地的组
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有满足条件的怪兽组
	local mg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择2只满足条件的怪兽组
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作：将标记的怪兽组送去墓地并清除标记
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将怪兽组送去墓地作为特殊召唤的代价
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤满足条件的地属性怪兽：表侧表示、具有攻击力
function s.atkfilter(c)
	-- 表侧表示且具有攻击力的地属性怪兽
	return aux.nzatk(c) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 设置攻击力上升效果的目标：选择1只地属性怪兽作为目标
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 判断是否能选择目标：检查场上是否存在满足条件的地属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只地属性怪兽作为目标
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 执行攻击力上升效果：将目标怪兽攻击力的一半加到自身攻击力上，持续到回合结束
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain()
		and c:IsFaceup() and c:IsRelateToChain() then
		-- 将目标怪兽攻击力的一半加到自身攻击力上，持续到回合结束
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(math.ceil(tc:GetAttack()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 判断是否满足破坏时回到手卡效果的发动条件：该卡因破坏而送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 设置回到手卡效果的目标：确认该卡可以回到手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：该卡将回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行回到手卡效果：将该卡送入手卡并确认对方看到
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否能正常处理且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将该卡送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对方看到该卡
		Duel.ConfirmCards(1-tp,c)
	end
end
