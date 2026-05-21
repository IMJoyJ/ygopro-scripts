--GP－ネック・アンド・ネック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「黄金荣耀」怪兽或者「黄金荣耀-并驾齐驱」以外的自己墓地1张「黄金荣耀」卡为对象才能发动。那张卡回到手卡。
-- ②：持有比自己基本分数值高的攻击力的怪兽在对方场上存在的场合，从自己墓地把这张卡和1只「黄金荣耀」怪兽除外才能发动。把有除外的怪兽的卡名记述的1只「黄金荣耀」怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（魔法卡发动）和②效果（墓地诱发即时效果）
function s.initial_effect(c)
	-- ①：以自己场上1只「黄金荣耀」怪兽或者「黄金荣耀-并驾齐驱」以外的自己墓地1张「黄金荣耀」卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：持有比自己基本分数值高的攻击力的怪兽在对方场上存在的场合，从自己墓地把这张卡和1只「黄金荣耀」怪兽除外才能发动。把有除外的怪兽的卡名记述的1只「黄金荣耀」怪兽从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上的「黄金荣耀」怪兽，或者自己墓地「黄金荣耀-并驾齐驱」以外的「黄金荣耀」卡，且这些卡能回到手卡
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x192) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ①效果的发动准备，包括判断合法对象、选择对象并将其设为效果处理的目标，以及设置回收手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 在发动时，检查自己场上或墓地是否存在至少1个满足条件的「黄金荣耀」卡作为对象
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1个满足条件的「黄金荣耀」卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表示该效果包含将选中的1张卡送回手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的实际处理，将选中的对象卡送回持有者手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第1个（也是唯一一个）对象卡
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡在效果处理时仍与该效果相关联，则将其送回持有者的手卡
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
-- 过滤对方场上表侧表示存在且攻击力高于自己当前基本分的怪兽
function s.cfilter(c,lp)
	return c:IsFaceup() and c:GetAttack()>lp
end
-- ②效果的发动条件判定，检查对方场上是否存在攻击力比自己基本分高的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力大于自己当前基本分的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,Duel.GetLP(tp))
end
-- 过滤自己墓地中可以作为cost除外的「黄金荣耀」怪兽，且额外卡组中存在记述了该怪兽卡名的「黄金荣耀」怪兽可以特殊召唤
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x192) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查额外卡组中是否存在至少1只记述了该墓地怪兽卡名且可以特殊召唤的「黄金荣耀」怪兽
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
-- 过滤额外卡组中记述了指定卡名、可以被特殊召唤且额外怪兽区域有空位的「黄金荣耀」怪兽
function s.sfilter(c,e,tp,code)
	-- 检查卡片是否属于「黄金荣耀」系列、是否在文本中记述了指定的卡名，并且是否可以被特殊召唤
	return c:IsSetCard(0x192) and aux.IsCodeListed(c,code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有可用于从额外卡组特殊召唤该怪兽的可用区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动代价（Cost）处理，将墓地的这张卡和1只「黄金荣耀」怪兽除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，首先检查作为Cost的墓地中的这张卡本身是否可以除外
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 并检查自己墓地中是否存在另一只满足条件的「黄金荣耀」怪兽可以作为Cost除外
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给发动效果的玩家发送提示信息，提示其选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的「黄金荣耀」怪兽作为Cost除外
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	g:AddCard(e:GetHandler())
	-- 将选中的墓地怪兽和这张卡本身以表侧表示除外，作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动准备，在Cost支付成功后，设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置当前连锁的操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的实际处理，从额外卡组特殊召唤1只记述了除外怪兽卡名的「黄金荣耀」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只记述了被除外怪兽卡名的「黄金荣耀」怪兽
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 then
		-- 将选中的「黄金荣耀」怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
