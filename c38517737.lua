--青眼の亜白龍
-- 效果：
-- 这张卡不能通常召唤。把手卡1只「青眼白龙」给对方观看的场合可以特殊召唤。这个方法的「青眼亚白龙」的特殊召唤1回合只能有1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「青眼白龙」使用。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
function c38517737.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把手卡1只「青眼白龙」给对方观看的场合可以特殊召唤。这个方法的「青眼亚白龙」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38517737+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c38517737.spcon)
	e1:SetTarget(c38517737.sptg)
	e1:SetOperation(c38517737.spop)
	c:RegisterEffect(e1)
	-- 为这张卡注册在场上·墓地卡名当作「青眼白龙」使用的规则效果，对应①效果。
	aux.EnableChangeCode(c,89631139,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：1回合1次，以对方场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38517737,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c38517737.descost)
	e3:SetTarget(c38517737.destg)
	e3:SetOperation(c38517737.desop)
	c:RegisterEffect(e3)
end
-- 筛选条件：手卡中卡名是「青眼白龙」且当前不是公开状态的卡，用于作为特殊召唤时给对方确认的展示卡。
function c38517737.spcfilter(c)
	return c:IsCode(89631139) and not c:IsPublic()
end
-- 特殊召唤手续的条件：若c为空则视为该规则效果的公开信息；否则检查自己场上是否存在可用怪兽区，且手卡有1张可作为展示的「青眼白龙」。
function c38517737.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有至少1个可用的主要怪兽区空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张符合spcfilter的「青眼白龙」（卡名正确且非公开），以供展示。
		and Duel.IsExistingMatchingCard(c38517737.spcfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 特殊召唤手续的目标选择：从手卡选出1张符合条件的「青眼白龙」，将其记录到效果中，若选择成功返回true。
function c38517737.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中所有满足spcfilter条件的「青眼白龙」，形成候选集合供玩家选择。
	local g=Duel.GetMatchingGroup(c38517737.spcfilter,tp,LOCATION_HAND,0,nil)
	-- 显示选择提示文字“请选择给对方确认的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的对应操作：把之前选择的「青眼白龙」给对方确认，然后洗切手卡。
function c38517737.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的那张「青眼白龙」展示给对手玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 确认后洗切自己的手卡，以防止手牌信息被非公开获取。
	Duel.ShuffleHand(tp)
end
-- 破坏效果的发动代价：确认这张卡本回合未进行过攻击宣言；随后给自己附加本回合不能攻击的誓约效果。
function c38517737.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- （这个效果发动的回合，这张卡不能攻击）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- ②效果的发动目标：选择对方场上的1只怪兽作为对象，并设置破坏相关的操作信息。
function c38517737.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示文字“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象，并自动建立该对象与本连锁的关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将当前连锁的操作信息设置为破坏效果，对象为刚才选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的发动处理：取得效果对象，若该对象仍与效果相关则将其破坏。
function c38517737.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中作为对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
