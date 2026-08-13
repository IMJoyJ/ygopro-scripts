--カオス・ビースト－混沌の魔獣－
-- 效果：
-- 光属性调整＋调整以外的暗属性怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升1000。
-- ②：以除外的1只自己的光·暗属性怪兽为对象才能发动。那只怪兽加入手卡。
-- ③：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
local s,id,o=GetID()
-- 定义混沌之魔兽的初始化函数：注册同调召唤手续、苏生限制，以及①攻击力上升、②回收除外怪兽、③从墓地特召三个效果，并注册全局的除外事件监听用①的条件标记。
function s.initial_effect(c)
	-- 设置同调召唤素材：光属性调整 + 调整以外的暗属性怪兽1只以上（数量至少1，上限默认99）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- ①：这个回合是已有卡被除外的场合，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- ②：以除外的1只自己的光·暗属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置③效果的发动条件：这张卡送去墓地的回合不能发动（aux.exccon判断当前回合是否为其被送去墓地的回合，因返回效果离场时例外）。
	e3:SetCondition(aux.exccon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 光属性调整＋调整以外的暗属性怪兽1只以上。这个卡名的②③的效果1回合各能使用1次。①：这个回合是已有卡被除外的场合，这张卡的攻击力上升1000。②：以除外的1只自己的光·暗属性怪兽为对象才能发动。那只怪兽加入手卡。③：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.checkop)
		-- 将全局的除外事件监听效果ge1注册到玩家0（全局），使任何除外事件都会触发s.checkop，用于记录本回合已有卡被除外。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 除外事件触发时的操作：为玩家0注册一个持续到结束阶段的标记，表示本回合已有卡被除外，供①效果的条件判断使用。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一个id为卡片编号、持续到结束阶段时重置的标记（数量1），标记本回合已有卡被除外。
	Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
end
-- ①攻击力上升效果的适用条件：检查本回合是否已有卡被除外的标记，若有则适用。
function s.rmcon(e)
	-- 返回本回合“已有卡被除外”的标记数量是否大于0，作为①效果的适用条件。
	return Duel.GetFlagEffect(0,id)>0
end
-- ②效果的取对象过滤器：对象需在我方除外区、表侧表示、属性为光或暗，且可以被加入手牌。
function s.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ②效果的目标选择函数：检查我方除外区存在符合条件的卡，提示选择1张作为对象，并设置回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	-- 在发动时确认我方除外区是否存在至少1张满足s.thfilter的卡，作为②效果的发动条件。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向操作者显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己除外区选择1张满足s.thfilter的卡，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息：本连锁将处理1张卡加入手牌，对象为g。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若对象仍与效果相关则将其加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象卡（因为只选1张，所以用GetFirstTarget获取唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者手牌（nil表示回持有者手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③效果的代价过滤器：卡可以作为除外代价，且属性为光或暗。
function s.costfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ③效果发动时的代价处理：从手卡和墓地中选择这张卡以外的光、暗属性怪兽各1张，将其表侧除外作为cost。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己手卡和墓地获取所有可作为代价且不是这张卡自身的卡，作为代价候选集合。
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler())
	-- 检查候选集合中是否存在一组2张卡，其中1张为光属性、另1张为暗属性，以满足③的cost条件。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 向操作者显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从候选集合中选择2张卡，需要满足光、暗属性各1张的条件，作为实际除外的代价。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选中的素材卡以表侧表示除外，作为③效果发动的cost。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ③效果的目标/条件函数：确认自己场上有空位且该卡可以被特殊召唤，满足则登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区是否有空位，以决定能否特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：本连锁将涉及把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：若这张卡仍与效果相关，则将其从墓地特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地以表侧攻击表示特殊召唤到自己场上（检查召唤条件与苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
