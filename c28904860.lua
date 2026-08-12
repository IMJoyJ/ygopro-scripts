--Angelechy Bastion
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 可以以和这张卡相同纵列的1张其他卡为对象；那张卡除外。
-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合：可以从额外卡组把1只「四军之具象天使」当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置。
-- 「牙城之具象天使」的以上效果1回合各能使用1次。
-- 这张卡当作永续魔法卡使用中的场合，场上的其他「具象天使」卡不会被对方的卡的效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果：登记记载的卡名、设置同调召唤手续与苏生限制，并注册5个效果：除外同纵列卡的起动效果、在魔陷区作为永续魔法时赋予全场其他「具象天使」卡效果破坏抗性的永续效果、移动时的连续辅助效果、连锁处理完毕后的连续辅助效果、被放置到魔陷区时触发的从额外卡组放置「四军之具象天使」的诱发效果
function s.initial_effect(c)
	-- 登记这张卡上记载着卡号为42410161的卡（「四军之具象天使」）的卡名
	aux.AddCodeList(c,42410161)
	-- 为这张卡添加同调召唤手续：素材为1只调整加调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 可以以和这张卡相同纵列的1张其他卡为对象；那张卡除外。（此效果1回合只能使用1次）
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
	-- 这张卡当作永续魔法卡使用中的场合，场上的其他「具象天使」卡不会被对方的卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.indtg)
	-- 设置效果值：只赋予不被对方的卡的效果破坏的抗性（判定发动效果的玩家是否为对方）
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 注册持续监测自身移动的单体连续效果，为「这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合」的诱发效果做时点准备
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_MOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetOperation(s.flagop)
	c:RegisterEffect(e3)
	-- 注册在连锁处理完毕后触发的连续辅助效果，用于在连锁中移动时延迟引发「这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合」的时点
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.raiseop)
	c:RegisterEffect(e4)
	-- 这张卡被当作永续魔法卡使用在魔法与陷阱区域放置的场合：可以从额外卡组把1只「四军之具象天使」当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置。（此效果1回合只能使用1次）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"放置效果"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CUSTOM+id)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+o)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
-- 除外对象的过滤函数：该卡可以除外，且包含在与这张卡相同的纵列中
function s.rmfilter(c,g)
	return c:IsAbleToRemove() and g:IsContains(c)
end
-- 除外效果的对象选择处理：取得与这张卡相同纵列的卡组，确认场上存在可作为对象的卡，让玩家选择其中1张其他卡为对象并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.rmfilter(chkc,g) and chkc~=c end
	-- 发动条件检查：场上存在至少1张满足除外条件、与这张卡同纵列的其他卡可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,g) end
	-- 向玩家提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择与这张卡同纵列的1张其他卡作为效果对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,g)
	-- 设置操作信息：本次连锁将除外作为对象的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的处理：取得对象卡，若其仍与连锁相关且在场，则以表侧表示将其除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 以效果处理为由将对象卡以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 自身移动时的连续处理：若这张卡以永续魔法卡身份处于魔法与陷阱区域，且当前在连锁处理中则登记旗标延迟到连锁处理后，否则立即引发「被放置到魔陷区」的自定义事件
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	-- 判断当前是否处于连锁处理中（若是则延迟引发事件，避免错过时点）
	if Duel.GetCurrentChain()>0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	else
		-- 为这张卡引发单体自定义事件，通知「被当作永续魔法卡使用在魔法与陷阱区域放置」的时点
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 连锁处理完毕时的连续处理：若这张卡是永续魔法卡且登记了移动旗标，则补发「被放置到魔陷区」的自定义事件
function s.raiseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	if c:GetFlagEffect(id)~=0 then
		-- 为这张卡引发单体自定义事件，补发「被当作永续魔法卡使用在魔法与陷阱区域放置」的时点
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 永续魔法状态条件：这张卡的当前种类为永续魔法卡
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 放置对象的过滤函数：卡名为「四军之具象天使」（卡号42410161）且未被禁止使用
function s.setfilter(c)
	return c:IsCode(42410161) and not c:IsForbidden()
end
-- 放置效果的发动条件检查：额外卡组存在可放置的「四军之具象天使」，自己的魔法与陷阱区域有空位，且这张卡正以永续魔法卡身份使用中
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1张满足条件的「四军之具象天使」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检查自己的魔法与陷阱区域是否还有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS end
end
-- 放置效果的处理：确认魔陷区有空位后，让玩家从额外卡组选择1只「四军之具象天使」，将其以表侧表示放置到自己的魔法与陷阱区域，并赋予其永续魔法卡的种类
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的魔法与陷阱区域没有空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家提示「请选择要放置到场上的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从额外卡组选择1只满足条件的「四军之具象天使」
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 把选择的卡以表侧表示移动到自己的魔法与陷阱区域并立即适用其效果
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用在自己的魔法与陷阱区域以表侧表示放置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 抗性适用对象的过滤函数：场上表侧表示存在的这张卡以外的「具象天使」卡
function s.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1e2) and c~=e:GetHandler()
end
