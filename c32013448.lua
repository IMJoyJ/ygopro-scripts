--宵闇の騎士
-- 效果：
-- 「宵暗之骑士」的①②的效果1回合各能使用1次。
-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。
-- ●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
-- ●1回合1次，自己主要阶段才能发动。对方手卡随机选1张直到下次的对方结束阶段里侧表示除外。
-- ②：墓地的这张卡被除外的场合才能发动。从卡组把1只仪式怪兽加入手卡。
function c32013448.initial_effect(c)
	-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,32013448)
	e1:SetCondition(c32013448.mtcon)
	e1:SetOperation(c32013448.mtop)
	c:RegisterEffect(e1)
	-- ②：墓地的这张卡被除外的场合才能发动。从卡组把1只仪式怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,32013449)
	e2:SetCondition(c32013448.thcon)
	e2:SetTarget(c32013448.thtg)
	e2:SetOperation(c32013448.thop)
	c:RegisterEffect(e2)
end
-- 作为仪式召唤素材时，素材中存在「混沌战士」字段怪兽，且此卡此前不在超量素材区域时，条件成立。
function c32013448.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and eg:IsExists(Card.IsSetCard,1,nil,0x10cf)
		and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- ①效果处理：选择仪式召唤使用的「混沌战士」怪兽，为其赋予除外对方怪兽和随机除外对方手卡两个效果；若其不是效果怪兽则追加效果怪兽种类，并附加提示标记。
function c32013448.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x10cf)
	local rc=g:GetFirst()
	if not rc then return end
	-- ●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(32013448,0))  --"对方场上1只怪兽除外（宵暗之骑士）"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c32013448.rmtg)
	e1:SetOperation(c32013448.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	-- ●1回合1次，自己主要阶段才能发动。对方手卡随机选1张直到下次的对方结束阶段里侧表示除外。
	local e2=Effect.CreateEffect(rc)
	e2:SetDescription(aux.Stringid(32013448,1))  --"对方手卡随机1张暂时除外（宵暗之骑士）"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c32013448.rmtg2)
	e2:SetOperation(c32013448.rmop2)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(32013448,2))  --"「宵暗之骑士」效果适用中"
end
-- 第一个赋予效果的取对象处理：选择对方场上1只可以除外的怪兽作为对象，并设置除外操作信息。
function c32013448.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动时确认对方场上是否存在可作为对象的可除外怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1只可除外的怪兽并设为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息登记为除外所选的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：取得对象，若对象仍与此效果关联则将其除外。
function c32013448.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中记录的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 第二个赋予效果的发动处理：确认对方手牌存在可除外的卡，并设置随机除外1张手牌的操作信息。
function c32013448.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认对方手牌中是否存在可以被除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	-- 设置本次效果为从对方手牌随机除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 处理时随机选对方1张手牌里侧表示除外，标记它并布置在对方结束阶段送回手牌的效果。
function c32013448.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方手牌中所有满足除外条件的卡，用于随机抽取。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp,POS_FACEDOWN)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	local tc=sg:GetFirst()
	-- 将随机选中的那张卡以里侧表示除外。
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	tc:RegisterFlagEffect(32013448,RESET_EVENT+RESETS_STANDARD,0,1)
	-- ●1回合1次，自己主要阶段才能发动。对方手卡随机选1张直到下次的对方结束阶段里侧表示除外；②：墓地的这张卡被除外的场合才能发动。从卡组把1只仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c32013448.retcon)
	e1:SetOperation(c32013448.retop)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将‘结束阶段返回手牌’的效果作为场上持续效果注册，由tp玩家控制。
	Duel.RegisterEffect(e1,tp)
end
-- 返回效果的条件：被除外的卡仍带有本次效果标记，且当前为对方的结束阶段；若标记已消失则重置该返回效果。
function c32013448.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(32013448)==0 then
		e:Reset()
		return false
	else
		-- 判定当前回合玩家不是效果发动方，即已到对方回合。
		return Duel.GetTurnPlayer()~=tp
	end
end
-- 结束阶段处理：将被暂时除外的卡送回持有者手卡。
function c32013448.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将那张卡加入其持有者手卡。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- ②效果的发动条件：此卡在被除外前位于墓地。
function c32013448.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤条件：卡的类型为仪式怪兽（type包含RITUAL）且可以加入手卡。
function c32013448.thfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- ②效果的发动时点：确认卡组中存在符合条件的仪式怪兽，并设置检索加入手卡的操作信息。
function c32013448.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在可加入手卡的仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32013448.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次处理为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只仪式怪兽加入手卡，并展示给对手确认。
function c32013448.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1只满足条件的仪式怪兽。
	local g=Duel.SelectMatchingCard(tp,c32013448.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的仪式怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
