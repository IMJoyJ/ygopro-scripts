--バトル・サバイバー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的战斗阶段结束时才能发动。从这次战斗阶段中在这只怪兽表侧表示存在期间被送去自己墓地的卡之中把「战斗幸存者」以外的1张卡从自己墓地选出加入手卡。
function c64178868.initial_effect(c)
	-- ①：自己·对方的战斗阶段结束时才能发动。从这次战斗阶段中在这只怪兽表侧表示存在期间被送去自己墓地的卡之中把「战斗幸存者」以外的1张卡从自己墓地选出加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64178868,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,64178868)
	e1:SetTarget(c64178868.thtg)
	e1:SetOperation(c64178868.thop)
	c:RegisterEffect(e1)
	-- 从这次战斗阶段中在这只怪兽表侧表示存在期间被送去自己墓地的卡之中
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c64178868.regcon)
	e2:SetOperation(c64178868.regop)
	c:RegisterEffect(e2)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e1:SetLabelObject(ng)
	e2:SetLabelObject(ng)
end
-- 检查当前是否处于战斗阶段的条件函数
function c64178868.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段开始到战斗阶段结束之间
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 记录在战斗阶段中且此卡表侧表示存在期间送去自己墓地的卡，并给这些卡和此卡添加标记
function c64178868.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetLabelObject()
	if c:GetFlagEffect(64178868)==0 then
		sg:Clear()
		c:RegisterFlagEffect(64178868,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
	local g=eg:Filter(Card.IsControler,nil,tp)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(64178868,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		sg:AddCard(tc)
		tc=g:GetNext()
	end
end
-- 过滤出带有标记、可以加入手卡、不是「战斗幸存者」且当前存在于墓地中的卡
function c64178868.thfilter(c)
	return c:GetFlagEffect(64178868)~=0 and c:IsAbleToHand() and not c:IsCode(64178868) and c:IsLocation(LOCATION_GRAVE)
end
-- 效果①的发动准备与合法性检测，检查是否存在符合条件的卡，并设置回收手牌的操作信息
function c64178868.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ng=e:GetLabelObject()
	if chk==0 then return ng and ng:GetCount()>0 and ng:IsExists(c64178868.thfilter,1,nil) end
	-- 设置连锁的操作信息为：从墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的效果处理，让玩家从记录的卡中选择1张不受王家长眠之谷影响的卡加入手卡并展示
function c64178868.thop(e,tp,eg,ep,ev,re,r,rp)
	local ng=e:GetLabelObject()
	if not ng or ng:GetCount()==0 then return end
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从记录的卡中选择1张满足过滤条件且不受「王家长眠之谷」影响的卡
	local g=ng:FilterSelect(tp,aux.NecroValleyFilter(c64178868.thfilter),1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
