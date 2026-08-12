--ヴィサス＝アムリターラ
-- 效果：
-- 调整1只以上＋光属性怪兽1只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「维萨斯-斯塔弗罗斯特」使用。
-- ②：这张卡同调召唤的场合才能发动。从卡组把有「维萨斯-斯塔弗罗斯特」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ③：自己主要阶段才能发动。自己场上1只怪兽破坏。这个回合中自己场上的同调怪兽的攻击力上升800。
local s,id,o=GetID()
-- 初始化卡片效果，注册同调召唤手续、卡名变更效果、同调召唤成功时检索魔陷的效果以及主要阶段破坏怪兽并提升同调怪兽攻击力的效果。
function s.initial_effect(c)
	-- 设置该卡在怪兽区域存在时，卡名当作「维萨斯-斯塔弗罗斯特」使用。
	aux.EnableChangeCode(c,56099748)
	-- 注册同调召唤手续：调整1只以上＋光属性怪兽1只。
	aux.AddSynchroMixProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- 调整1只以上
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- ②：这张卡同调召唤的场合才能发动。从卡组把有「维萨斯-斯塔弗罗斯特」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ③：自己主要阶段才能发动。自己场上1只怪兽破坏。这个回合中自己场上的同调怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 素材检测函数，若同调素材中存在2只以上的调整怪兽，则为自身注册一个特定的标记效果（用于处理多调整同调的规则限制）。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 调整1只以上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索效果的发动条件：这张卡是同调召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检索卡片的过滤条件：卡名记述了「维萨斯-斯塔弗罗斯特」的魔法·陷阱卡，且能加入手卡。
function s.thfilter(c)
	-- 检查卡片是否记述了「维萨斯-斯塔弗罗斯特」且为魔法·陷阱卡，并且可以加入手卡。
	return aux.IsCodeListed(c,56099748) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 检索效果的发动准备（Target）：检查卡组中是否存在符合条件的卡，并向双方玩家宣告将要把卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理（Operation）：从卡组选择1张符合条件的卡加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏效果的发动准备（Target）：获取自己场上的怪兽作为破坏候选，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有的怪兽。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁处理的操作信息，表示该效果会破坏自己场上的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理（Operation）：选择自己场上1只怪兽破坏，并注册一个使自己场上同调怪兽攻击力上升800的全局效果。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家在自己场上选择1只怪兽。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		-- 选中目标卡片并显示被选为对象的动画效果。
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
	-- 这个回合中自己场上的同调怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(800)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该攻击力上升的场地/玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击力上升效果的适用对象过滤：自己场上的同调怪兽。
function s.atktg(e,c)
	return c:IsType(TYPE_SYNCHRO)
end
