--超電導戦士 リニア・マグナム±
-- 效果：
-- 这张卡不能通常召唤。「超电导战士 线性磁炮王±」1回合1次在从自己的手卡·卡组·场上（表侧表示）把2只原本等级是4星以下的「磁石战士」怪兽送去墓地的场合可以特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：以场上1只其他的地属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那个攻击力一半数值。
-- ②：这张卡被破坏送去墓地的场合发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册该怪兽的3个效果：特殊召唤规则效果e1、①起动效果e2、②诱发效果e3，并设置对应的发动条件和处理操作。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- “这张卡不能通常召唤。「超电导战士 线性磁炮王±」1回合1次在从自己的手卡·卡组·场上（表侧表示）把2只原本等级是4星以下的「磁石战士」怪兽送去墓地的场合可以特殊召唤。”——创建并注册特殊召唤规则效果，仅在手牌时适用，不可被无效、不可复制，并以誓约次数限制1回合1次。
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
	-- “这个卡名的①②的效果1回合各能使用1次。①：以场上1只其他的地属性怪兽为对象才能发动。这张卡的攻击力直到回合结束时上升那个攻击力一半数值。”——创建并注册①的起动效果，取对象，1回合1次。
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
	-- “②：这张卡被破坏送去墓地的场合发动。这张卡加入手卡。”——创建并注册②的诱发选发效果，在送去墓地时发动，场合型，1回合1次。
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
-- 筛选可作为特殊召唤素材的怪兽：表侧表示（手牌/卡组的表侧表示条件由IsFaceupEx处理）、属于「磁石战士」、原本等级4星以下、且可以作为COST送去墓地。
function s.tgfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x2066) and c:GetOriginalLevel()<5 and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的发动条件：确认这张卡可在手牌进行特殊召唤，且在自己的手牌·卡组·场上存在满足条件的素材，并保证送墓后仍有空余的怪兽区域。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得自己手牌·卡组·场上所有满足素材条件的「磁石战士」怪兽的集合。
	local mg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 检查素材集合中是否存在2张卡可以送去墓地，并且送墓后自己的怪兽区域仍有空位（满足aux.mzctcheck）。
	return mg:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 特殊召唤的发动时处理：提示玩家从素材集合中选择2张要送去墓地的卡，选中后保存该组素材并允许发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 再次检索手牌·卡组·场上所有满足素材条件的「磁石战士」怪兽，供玩家从中选择。
	local mg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 向玩家显示提示，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从素材集合中选择2张满足条件的卡，并确认送墓后仍有怪兽区空位；选择成功则作为特殊召唤素材。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤的处理：将之前选择并保存的2张素材怪兽送去墓地，完成特殊召唤手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为素材的2只怪兽以特殊召唤手续（REASON_SPSUMMON）送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义①效果可选对象的过滤条件：表侧表示、攻击力不为0的地属性怪兽。
function s.atkfilter(c)
	-- 对象必须同时满足：攻击力不为0的表侧表示怪兽，以及地属性。
	return aux.nzatk(c) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- ①效果的发动时处理：选择场上1只除了自身以外、符合过滤条件的地属性怪兽作为对象，并进行取对象操作。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 发动合法性检查：场上是否存在1只符合条件且可被选择为对象的地属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 向玩家显示提示，要求选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方场上的怪兽中选择1张表侧表示地属性怪兽（不能选择自身）作为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- ①效果处理：取得对象怪兽的攻击力，计算其一半数值（向上取整），让这张卡的攻击力直到回合结束时上升该数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain()
		and c:IsFaceup() and c:IsRelateToChain() then
		-- “这张卡的攻击力直到回合结束时上升那个攻击力一半数值。”——创建并注册一个单次攻击力上升效果，上升值为对象怪兽当前攻击力的一半（向上取整），持续到回合结束。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(math.ceil(tc:GetAttack()/2))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：这张卡是被破坏并因此被送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- ②效果的发动时判定：确认这张卡可以加入手卡，并设置“加入手卡”的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 将本效果的处理信息登记为“这张卡加入手卡”，供连锁处理时参考。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在连锁中且不受王家长眠之谷影响，则将其加入持有者手卡，并让对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前确认这张卡仍与当前连锁相关，且没有被王家长眠之谷等效果限制不能加入手卡。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入其持有者的手卡（REASON_EFFECT）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对手确认这张卡已经加入手卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
