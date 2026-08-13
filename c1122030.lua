--アルトメギア・ヴァンダリズム－襲撃－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「无垢者 米底乌斯」加入手卡。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，把那只表侧表示怪兽作为融合素材的场合，可以当作「神艺」怪兽使用。
-- ③：自己场上的「神艺学都 神艺学园」被效果破坏的场合，可以作为代替把场上的这张卡送去墓地。
local s,id,o=GetID()
-- 注册三个效果：①发动时从卡组把1只「无垢者 米底乌斯」加入手卡；②以自己场上1只表侧表示怪兽为对象，本回合其可作为「神艺」融合素材；③自己场上的「神艺学都 神艺学园」被效果破坏时可把此卡送墓代替。
function s.initial_effect(c)
	-- 将该卡关联的卡名「无垢者 米底乌斯」（97556336）和「神艺学都 神艺学园」（74733322）登记到代码表，用于规则上视为记载这些卡名。
	aux.AddCodeList(c,97556336,74733322)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「无垢者 米底乌斯」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只表侧表示怪兽为对象才能发动。这个回合，把那只表侧表示怪兽作为融合素材的场合，可以当作「神艺」怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"当作「神艺」怪兽"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
	-- ③：自己场上的「神艺学都 神艺学园」被效果破坏的场合，可以作为代替把场上的这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
-- 检索过滤条件：卡名为「无垢者 米底乌斯」且可以被加入手卡。
function s.thfilter(c)
	return c:IsCode(97556336) and c:IsAbleToHand()
end
-- ①效果的发动处理：从卡组中检索「无垢者 米底乌斯」，若存在且玩家选择发动检索，则选1张加入手卡并向对方展示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足检索条件（「无垢者 米底乌斯」且可加入手卡）的卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若检索候选不为空，且玩家确认要加入手卡，则继续执行检索。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽加入手卡？"
		-- 弹出选择提示，引导玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「无垢者 米底乌斯」送入持有者手卡，处理原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡，作为检索确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②的取对象筛选条件：选择自己场上表侧表示且原本不持有「神艺」字段的怪兽作为对象。
function s.filter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cd)
end
-- ②效果发动时的对象选择：从自己场上选择1只表侧表示且非「神艺」怪兽作为效果对象。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 效果发动条件检查：自己场上是否存在1只符合条件的表侧表示怪兽可供取对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，引导玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的己方表侧表示怪兽作为②效果的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的适用处理：若对象怪兽仍在场上且为表侧表示怪兽，则给它注册本回合可作为「神艺」融合素材的效果，并附加客户端提示标记。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「神艺学的破坏-袭击-」效果适用中"
		-- 这个回合，把那只表侧表示怪兽作为融合素材的场合，可以当作「神艺」怪兽使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_FUSION_SETCODE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(0x1cd)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 代替破坏的判定：被破坏的卡须是自己场上表侧表示的「神艺学都 神艺学园」，破坏原因为效果，且不是由代替破坏产生。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsCode(74733322) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏触发条件：此卡未被确认破坏，且存在因效果将被破坏的自己场上的「神艺学都 神艺学园」。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否用此卡代替破坏；选择“是”才执行代替送墓。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的判定回调：判断即将被破坏的卡是否满足代替条件（即被效果破坏的自己场上的「神艺学都 神艺学园」）。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的处理：发动方确认后，将此卡送去墓地以代替「神艺学都 神艺学园」被破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 把这张「神艺学的破坏-袭击-」以效果原因送去墓地，代替「神艺学都 神艺学园」的破坏。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
