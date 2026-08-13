--地縛戒隷 ジオグレムリーナ
-- 效果：
-- 「地缚」怪兽＋暗属性怪兽
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「地缚」怪兽加入手卡。
-- ②：以自己场上1只暗属性同调怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
-- ③：对方场上的怪兽被「地缚」卡的效果破坏的场合，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 初始化卡牌效果：解除苏生限制，添加融合召唤手续（「地缚」怪兽＋暗属性怪兽），并依次注册①检索、②直接攻击、③伤害三个1回合1次的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：将满足‘卡名含「地缚」’和‘暗属性’两个条件的怪兽各1只作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x21),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只「地缚」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只暗属性同调怪兽为对象才能发动。这个回合，那只怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果②的发动条件为当前处于主要阶段或战斗阶段（aux.bpcon），即允许在该阶段发动效果。
	e2:SetCondition(aux.bpcon)
	e2:SetTarget(s.dirtg)
	e2:SetOperation(s.dirop)
	c:RegisterEffect(e2)
	-- ③：对方场上的怪兽被「地缚」卡的效果破坏的场合，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：卡组中的‘卡名含「地缚」’的怪兽，并且能够加入手卡（即没有‘不能加入手卡’限制）。
function s.filter(c)
	return c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动条件判断与目标信息设置：若卡组存在符合条件的「地缚」怪兽，则允许发动，并设置本次效果为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查卡组是否存在至少1张满足s.filter的「地缚」怪兽，以决定是否满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果是检索卡牌，将从卡组把1张卡加入持有者手卡，数量1，检索者为tp。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理时：从卡组选择1张符合条件的「地缚」怪兽加入手卡，并向对方公开确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让当前玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从当前玩家卡组中选出1张符合s.filter条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示返回持有者手卡），原因视为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义效果②的对象筛选条件：我方场上表侧表示、暗属性、同调怪兽，且没有被赋予直接攻击效果（避免重复）。
function s.dfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)
		and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果②的取对象处理：选择我方场上1只符合条件的暗属性同调怪兽；若指定了对象，则验证该对象是否位于我方怪兽区、控制者是我方且满足过滤条件。
function s.dirtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.dfilter(chkc) end
	-- 在效果发动时（chk==0）检查我方怪兽区是否存在至少1只符合s.dfilter条件的暗属性同调怪兽，以决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示‘请选择表侧表示的卡’的选择提示，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从我方场上选择1只符合条件的表侧暗属性同调怪兽作为效果对象。
	Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②处理时：给对象怪兽赋予本回合可以直接攻击的效果，并在回合结束或离开场上等时机自动重置。
function s.dirop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②所选中的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽可以直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义效果③的触发筛选条件：被破坏的怪兽先前位于对方怪兽区、由对方控制、因效果而被破坏，且该效果来自「地缚」卡；其原本攻击力>0，不是衍生物，并且能成为效果对象。
function s.cfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsSetCard(0x21)
		and c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and not c:IsType(TYPE_TOKEN)
end
-- 效果③的发动条件与对象选择：从被破坏的一组怪兽中筛选出符合条件的对象；若存在则发动。若候选多于1只，则由玩家选择其中1只，并设置该怪兽为效果对象，同时记录伤害信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.cfilter(chkc,e,tp) end
	local g=eg:Filter(s.cfilter,nil,e,tp)
	if chk==0 then return #g>0 end
	-- 显示‘请选择效果的对象’的提示（用于选择被破坏的怪兽）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tc=g:GetFirst()
	if #g>1 then
		-- 当候选怪兽多于1只时，再次显示‘请选择效果的对象’提示，并进行选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	-- 将选中的怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息：本次效果将造成伤害，伤害值等于对象怪兽的原本攻击力，伤害对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetBaseAttack())
end
-- 效果③处理时：获取对象怪兽，若其仍与效果相关且原本攻击力>0，则对对方造成该原本攻击力数值的伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果③中所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:GetBaseAttack()>0 then
		-- 对对方玩家造成对象怪兽原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
