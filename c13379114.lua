--デーモンの気魄
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：额外怪兽区域有自己的「恶魔」仪式怪兽存在的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
-- ②：这张卡从手卡·场上除外的场合才能发动。从卡组把「恶魔的气魄」以外的1张「恶魔」卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片的3个效果：e1为使该魔陷能够发动的基础效果；e2为①效果，使对方场上1张表侧表示卡的效果无效直到回合结束时；e3为②效果，该卡从手卡·场上除外时从卡组检索「恶魔」卡；各效果分别设置发动条件、目标、处理与1回合1次限制后注册给该卡。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：额外怪兽区域有自己的「恶魔」仪式怪兽存在的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡·场上除外的场合才能发动。从卡组把「恶魔的气魄」以外的1张「恶魔」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：检查怪兽是否位于额外怪兽区域（区域编号>4）、是「恶魔」字段的仪式怪兽且表侧表示，用于①效果发动条件。
function s.cfilter(c)
	return c:GetSequence()>4 and c:IsSetCard(0x45) and c:IsType(TYPE_RITUAL)
		and c:IsFaceup()
end
-- ①效果的发动条件：己方场上的额外怪兽区域存在满足 s.cfilter 的「恶魔」仪式怪兽时才可发动。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 在己方怪兽区域检索是否存在至少1张满足 s.cfilter 的卡，作为发动条件的判定。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时的选择目标函数：从对方场上选择1张表侧表示且可被无效的卡作为对象，并设置操作信息为无效该卡。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象确认时检查该卡是否属于对方场上表侧表示且可通过 aux.NegateAnyFilter 被无效，否则不能成为对象。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 效果发动条件检查：对方场上是否存在至少1张满足 aux.NegateAnyFilter 的可无效卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 选择对象前向当前玩家显示“请选择要无效的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方场上选择1张满足 aux.NegateAnyFilter 的表侧表示卡作为对象，并自动与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次连锁处理将执行 CATEGORY_DISABLE（无效化），对象为已选择的目标，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：若对象卡仍表侧表示且与连锁相关并可被此效果无效，则将其效果无效直到回合结束时；具体为无效其关联连锁、赋予其无效怪兽效果和无效效果效果，对陷阱怪兽额外无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的目标卡（对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使该对象卡相关的连锁无效化，并将无效状态在卡片变里侧时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- ②效果的发动条件：这张卡被除外之前位于手卡或场上（从手卡·场上除外）时才可发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 定义②效果的检索过滤条件：属于「恶魔」字段、不是「恶魔的气魄」本身、且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x45) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ②效果的目标选择函数：检查卡组中是否存在符合条件的「恶魔」卡，并设置操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：卡组中是否存在至少1张满足 s.thfilter 的「恶魔」卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁处理将进行 CATEGORY_TOHAND（加入手卡），因为检索目标在处理时才确定，所以目标暂设为 nil，数量为1，从卡组选择。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：玩家从卡组选择1张符合条件的「恶魔」卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索时显示“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足 s.thfilter 的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因标记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
