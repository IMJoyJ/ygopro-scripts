--幻獄神メディクリウス
-- 效果：
-- 包含融合·同调·超量·连接怪兽的怪兽2只以上
-- ①：这张卡所连接区的怪兽数量让这张卡得到以下效果。
-- ●1只以上：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
-- ●2只以上：这张卡不受对方发动的效果影响。
-- ●3只：对方回合才能发动1次。这张卡以及对方场上的卡全部除外。
local s,id,o=GetID()
-- 初始化卡片效果：设置连接召唤手续与苏生限制，并注册3个效果——使对方怪兽效果无效并攻击力减半的起动效果、不受对方发动效果影响的永续效果、将这张卡与对方场上的卡全部除外的诱发即时效果
function s.initial_effect(c)
	-- 设置连接召唤手续：用2到3只满足过滤条件s.lcheck的怪兽作为连接素材进行连接召唤
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- ●1只以上：1回合1次，自己主要阶段才能发动。对方场上的全部表侧表示怪兽的效果无效化，那些攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.lmcon(1))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ●2只以上：这张卡不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.lmcon(2))
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ●3只：对方回合才能发动1次。这张卡以及对方场上的卡全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 连接素材过滤：检查素材组中是否存在至少1只融合·同调·超量·连接怪兽，以满足「包含融合·同调·超量·连接怪兽的怪兽2只以上」的素材要求
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 发动条件生成函数：返回一个条件函数，判断这张卡所连接区的怪兽数量是否大于等于指定数值ct
function s.lmcon(ct)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetLinkedGroupCount()>=ct
	end
end
-- ①效果的目标函数：发动检测时确认对方场上存在表侧表示怪兽，并取得对方场上全部表侧表示怪兽作为效果无效化的处理对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检查：对方场上必须存在至少1只表侧表示怪兽才能发动此效果
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上全部表侧表示怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：宣告将对该卡片组中的怪兽进行效果无效化处理（CATEGORY_DISABLE），数量为组内卡数
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果处理：将对方场上全部表侧表示怪兽的效果无效化，随后把这些怪兽的攻击力变成各自当前攻击力的一半（向上取整）直到回合结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新取得对方场上全部表侧表示怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历该卡片组中的每一只对方表侧表示怪兽
	for tc in aux.Next(g) do
		-- 将与该怪兽相关的连锁全部无效化，该怪兽变成里侧表示时重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 手动刷新场上卡的无效状态，使刚才注册的无效化效果立即生效
	Duel.AdjustInstantly()
	-- 再次遍历该卡片组中的每一只对方表侧表示怪兽，用于处理攻击力减半
	for tc in aux.Next(g) do
		local atk=tc:GetAttack()
		-- 那些攻击力直到回合结束时变成一半
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e3)
	end
end
-- 免疫效果过滤：只对由对方玩家发动的效果生效，即这张卡不受对方发动的效果影响
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
-- ③效果的发动条件：这张卡所连接区的怪兽数量为3只，并且当前是对方的回合
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroupCount()==3
		-- 条件判断：当前回合玩家不是自己，即对方回合
		and Duel.GetTurnPlayer()~=tp
end
-- ③效果的目标函数：发动检测时确认这张卡可以被除外，取得对方场上的全部卡并加入这张卡，作为除外的处理对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	-- 取得对方场上的全部卡组成的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	g:AddCard(c)
	-- 设置连锁操作信息：宣告将这组卡（对方场上的卡与这张卡）全部除外（CATEGORY_REMOVE），数量为组内卡数
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ③效果处理：取得对方场上的全部卡，若这张卡仍与该连锁相关则将其加入，把这张卡以及对方场上的卡全部表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方场上的全部卡组成的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToChain() then g:AddCard(c) end
	-- 以表侧表示形式、因效果原因将这组卡（这张卡以及对方场上的卡）全部除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
