--無死虫団の重騎兵
-- 效果：
-- 5星以上的昆虫族怪兽＋昆虫族怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，不会被对方的效果破坏。
-- ②：自己·对方回合，自己场上的表侧表示怪兽只有昆虫族怪兽的场合，以包含自己场上的昆虫族怪兽的场上2只怪兽为对象才能发动。那些怪兽除外。
local s,id,o=GetID()
-- 定义卡片的初始化函数，注册融合召唤手续、苏生限制、①不被对方效果破坏的永续效果以及②的除外效果。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续，融合素材为“5星以上的昆虫族怪兽”和“昆虫族怪兽”各1只。
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),true)
	c:EnableReviveLimit()
	-- ①：这张卡只要在怪兽区域存在，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	-- 设置①效果中“不会被对方的效果破坏”的判定条件，当效果发动者为这张卡的控制者的对方时，该破坏无效。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方回合，自己场上的表侧表示怪兽只有昆虫族怪兽的场合，以包含自己场上的昆虫族怪兽的场上2只怪兽为对象才能发动。那些怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 定义融合素材过滤器：选择昆虫族且等级在5星以上的怪兽，作为“5星以上的昆虫族怪兽”融合素材。
function s.matfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsLevelAbove(5)
end
-- 定义②效果的发动条件，检查自己场上的表侧表示怪兽是否只有昆虫族怪兽，只有满足时才可发动。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上不存在表侧表示且不是昆虫族的怪兽；若不存在，则“自己场上的表侧表示怪兽只有昆虫族怪兽”的条件成立。
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,aux.NOT(Card.IsRace)),tp,LOCATION_MZONE,0,1,nil,RACE_INSECT)
end
-- 定义候选对象过滤器：选择自己场上的表侧表示昆虫族怪兽，且该怪兽可以被除外，同时场上还存在另一只可除外的怪兽。
function s.rmfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAbleToRemove()
		-- 确认除候选怪兽外，场上还存在至少1只可除外的怪兽，从而能凑齐效果所需的2只对象。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 定义②效果的取对象流程：判断可发动后，先选择1只自己场上的昆虫族怪兽，再选择另1只双方场上的可除外怪兽，合并后设置除外信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动时（chk==0）检查是否存在至少1只满足s.rmfilter的候选目标，若存在则允许发动。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示消息，提示其选择第一只对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1只满足s.rmfilter的昆虫族怪兽作为第一对象，并登记为当前连锁的效果对象。
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次向玩家显示“请选择要除外的卡”的提示消息，提示其选择第二只对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方场上选择1只除第一对象以外可除外的怪兽作为第二对象，并登记为当前连锁的效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1)
	g1:Merge(g2)
	-- 设置连锁操作信息，声明将选择的两只怪兽以除外（CATEGORY_REMOVE）处理，数量为2，用于后续效果判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
-- 实现②效果处理时的执行函数：获取对象卡，筛除已经与效果失去联系的卡，然后将仍关联的怪兽除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果发动时登记的对象卡（两只怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将筛选后仍与效果关联的怪兽以表侧表示除外，执行“那些怪兽除外”的处理。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
