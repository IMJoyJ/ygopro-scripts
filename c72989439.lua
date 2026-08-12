--カオス・ソルジャー －開闢の使者－
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽各1只除外的场合可以特殊召唤。这张卡的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽除外。
-- ②：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
function c72989439.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72989439,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c72989439.spcon)
	e1:SetTarget(c72989439.sptg)
	e1:SetOperation(c72989439.spop)
	c:RegisterEffect(e1)
	-- ①：以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72989439,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c72989439.rmcost)
	e2:SetTarget(c72989439.rmtg)
	e2:SetOperation(c72989439.rmop)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72989439,2))  --"连续攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c72989439.atcon)
	e3:SetOperation(c72989439.atop)
	c:RegisterEffect(e3)
end
-- 过滤自身特殊召唤所需除外的墓地光·暗属性怪兽
function c72989439.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 自身特殊召唤的条件判定：检查怪兽区域是否有空位，以及墓地是否存在光·暗属性怪兽各1只
function c72989439.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己场上是否有可用的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有可以作为特殊召唤Cost除外的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c72989439.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查墓地中是否存在光属性和暗属性怪兽各1只的组合
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 自身特殊召唤的目标选择：从墓地选择光·暗属性怪兽各1只，并将其保存在效果标签对象中
function c72989439.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有可以作为特殊召唤Cost除外的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c72989439.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地中选择光属性和暗属性怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特殊召唤的实际操作：将选定的墓地怪兽除外
function c72989439.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选定的光·暗属性怪兽各1只表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 效果①的发动Cost：判定本回合是否未宣言攻击，并给自身添加本回合不能攻击的限制，同时注册已使用效果的标记
function c72989439.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- ①：以场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽除外。②：这张卡的攻击破坏对方怪兽时才能发动。这张卡只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
	c:RegisterFlagEffect(72989439,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果①的效果目标：检查并选择场上1只可以除外的怪兽作为对象，并设置除外操作信息
function c72989439.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 判定场上是否存在可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择场上1只可以被除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果会除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的实际处理：将作为对象的怪兽除外
function c72989439.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：自身攻击破坏对方怪兽、本回合未发动过另一个效果，且自身可以进行追加攻击
function c72989439.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前攻击怪兽是否为自身、是否通过战斗破坏了对方怪兽，且本回合没有使用过另一个效果（通过Flag标记判定）
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:GetFlagEffect(72989439)==0
		and c:IsChainAttackable()
end
-- 效果②的实际处理：使自身可以再进行1次攻击
function c72989439.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自身可以再进行1次攻击
	Duel.ChainAttack()
end
