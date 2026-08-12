--Angelechy Shatranga
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 可以以对方场上1只怪兽为对象；那只怪兽除外。
-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合：可以从自己的卡组·墓地把1张「具象天使」陷阱卡加入手卡。
-- 「四军之具象天使」的以上效果1回合各能使用1次。
-- 这张卡当作永续魔法卡使用中的场合，对方在1回合最多只能发动5次怪兽的效果。
local s,id,o=GetID()
-- 初始化这张卡的效果：注册同调召唤手续，并依次注册除外对方场上怪兽的起动效果（e1）、检测以永续魔法卡身份放置的永续效果（e2）、连锁处理后触发自定义事件的辅助效果（e3）、检索「具象天使」陷阱卡的诱发效果（e4）、对方怪兽效果发动次数计数（e5）、连锁被无效时的计数回退（e6）以及对方怪兽效果发动次数限制（e7）
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整加上1只以上调整以外的怪兽作为同调素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 可以以对方场上1只怪兽为对象；那只怪兽除外。「四军之具象天使」的以上效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_MOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)
	-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.raiseop)
	c:RegisterEffect(e3)
	-- 可以从自己的卡组·墓地把1张「具象天使」陷阱卡加入手卡。「四军之具象天使」的以上效果1回合各能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 这张卡当作永续魔法卡使用中的场合，对方在1回合最多只能发动5次怪兽的效果。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCondition(s.thcon)
	e5:SetOperation(s.count)
	c:RegisterEffect(e5)
	-- 这张卡当作永续魔法卡使用中的场合，对方在1回合最多只能发动5次怪兽的效果。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_CHAIN_NEGATED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCondition(s.thcon)
	e6:SetOperation(s.rst)
	c:RegisterEffect(e6)
	-- 这张卡当作永续魔法卡使用中的场合，对方在1回合最多只能发动5次怪兽的效果。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_ACTIVATE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(0,1)
	e7:SetCondition(s.econ)
	e7:SetValue(s.elimit)
	c:RegisterEffect(e7)
end
-- 过滤函数：判断卡是否能被除外
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 除外效果的对象选择：确认对方场上存在可成为对象的可除外怪兽，选择对方场上1只怪兽作为对象，并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 发动条件检查：对方场上存在1只以上能被除外且可以成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己玩家选择对方场上1只能被除外的怪兽作为这个效果的对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：确定将对象的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的处理：取得对象卡，若其仍与当前连锁关联且为怪兽，则以表侧表示将其除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的第一个对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 以效果为由将对象怪兽以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 永续魔法放置检测处理：若这张卡以永续魔法卡身份放置在魔法与陷阱区域，则当前有连锁在处理时先注册标志等待连锁结束，否则直接触发自定义事件作为检索效果的时点
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	-- 判断当前是否有连锁正在处理（有则延迟到连锁处理结束后再触发）
	if Duel.GetCurrentChain()>0 then
		c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	else
		-- 为这张卡触发自定义时点事件，用于诱发检索「具象天使」陷阱卡的效果
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 连锁处理结束时的处理：若这张卡仍是永续魔法卡且已注册放置标志，则触发自定义时点事件
function s.raiseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	if c:GetFlagEffect(id+o)~=0 then
		-- 触发检索效果的自定义时点事件
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 检索效果的发动条件：这张卡正作为永续魔法卡使用中
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 过滤函数：判断是否为「具象天使」系列（0x1e2）且能加入手卡的陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的目标设置：确认自己的卡组·墓地存在可加入手卡的「具象天使」陷阱卡，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己的卡组·墓地存在1张以上满足条件的「具象天使」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：从自己的卡组或墓地把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理：从自己的卡组·墓地选择1张「具象天使」陷阱卡加入手卡，并让对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「具象天使」陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 对方怪兽效果发动计数：对方发动怪兽效果时，为这张卡注册1个计数标志，记录本回合对方已发动的怪兽效果次数
function s.count(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
end
-- 连锁被无效时的计数回退：对方的怪兽效果发动被无效时，将这张卡的计数减少1（清除多余标志后重新注册剩余数量）
function s.rst(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return end
	local ct=e:GetHandler():GetFlagEffect(id)-1
	e:GetHandler():ResetFlagEffect(id)
	if ct>0 then
		for i=1,ct do
			e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x3ff0000+RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 限制生效条件：本回合对方已发动的怪兽效果次数超过5次
function s.econ(e)
	return e:GetHandler():GetFlagEffect(id)>4
end
-- 限制范围：仅限制对方怪兽效果的发动
function s.elimit(e,te,tp)
	return te:IsActiveType(TYPE_MONSTER)
end
