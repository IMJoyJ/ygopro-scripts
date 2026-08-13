--ポワソニエル・ド・ヌーベルズ
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上有仪式怪兽存在的场合，以场上1只怪兽为对象才能发动。这张卡特殊召唤。那之后，作为对象的怪兽的表示形式变更。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。
-- ●把1只1星仪式怪兽或者1张「食谱」卡从卡组加入手卡。
-- ●从自己墓地把「食谱」卡任意数量除外，把持有和那个数量相同等级的1只「新式魔厨」仪式怪兽从手卡特殊召唤。
-- ②：场上的这张卡被解放以表侧加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化函数，为这张卡注册灵摆召唤属性，以及灵摆效果①（特殊召唤自身并变更对象表示形式）、怪兽效果②（被解放表侧加入额外卡组时放置到灵摆区）、召唤/特殊召唤时选择发动的怪兽效果①（召唤成功与特殊召唤成功分支共用1回合1次限制）。
function s.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（灵摆召唤、灵摆刻度），使其可以作为灵摆卡从手牌发动到灵摆区。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己场上有仪式怪兽存在的场合，以场上1只怪兽为对象才能发动。这张卡特殊召唤。那之后，作为对象的怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被解放以表侧加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.pzcon)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合，可以从以下效果选择1个发动。●把1只1星仪式怪兽或者1张「食谱」卡从卡组加入手卡；●从自己墓地把「食谱」卡任意数量除外，把持有和那个数量相同等级的1只「新式魔厨」仪式怪兽从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.target)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤器s.cfilter：判断一张卡是否为表侧表示且为仪式怪兽，用于检查自己场上是否存在表侧仪式怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 灵摆效果①的发动条件：自己场上存在至少1张表侧表示且为仪式怪兽的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）是否存在至少1张满足s.cfilter的卡；存在则发动条件成立。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标选择函数s.sptg的定义：先处理取对象时的对象合法性检查（chkc）——对象需在怪兽区且可变更表示形式；随后进入发动时的合法性检查（chk==0）分支。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	local c=e:GetHandler()
	-- 发动时的合法性检查第一项：场上（双方主要怪兽区）存在至少1只可变更表示形式的怪兽，可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 发动时的合法性检查第二项：自己场上有可用怪兽区，且自身可以以表侧表示被效果特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家显示选择提示“请选择要改变表示形式的怪兽”，用于之后选择对象时的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方场上选择1只可变更表示形式的怪兽作为效果对象，并将该对象与当前连锁关联。
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果包含‘变更表示形式’分类，对象为所选怪兽g，数量1，供其他卡效果检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：本次效果包含‘特殊召唤’分类，对象为自身c，数量1，供其他卡效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果①的发动处理：先将自身特殊召唤；若失败或自身已与效果失去关联则结束。若成功且对象仍合法，则中断连锁后变更对象怪兽的表示形式。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身已与效果失去关联，或特殊召唤自身失败（实际特召数量<1），则不再进行后续处理。
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)<1 then return end
	-- 获取本效果的对象（即要变更表示形式的1只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续‘变更表示形式’作为独立时点处理，避免错时点/错过时点。
		Duel.BreakEffect()
		-- 变更对象怪兽的表示形式：原攻击表示变为守备表示，原守备表示变为攻击表示（具体为表侧攻击→表侧守备、里侧攻击→里侧守备、表侧守备→表侧攻击、里侧守备→表侧攻击）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 怪兽效果②的发动条件：这张卡之前在场上，因被解放而表侧加入额外卡组（即从场上表侧被解放送进额外卡组）时，可以发动。
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_RELEASE) and c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 怪兽效果②的发动条件检查：自己灵摆区左/右任意一侧有空位即可发动（发动时无需选择对象）。
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区左侧（序号0）或右侧（序号1）是否存在可用格位；只要有一侧为空则满足发动条件。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的发动处理：若这张卡仍与效果关联，则将其移动到自己的灵摆区并适用（表侧放置）。
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认卡片与效果仍有关联后，将这张卡移动到己方灵摆区（表侧表示），并立刻适用其作为灵摆卡的效果。
	if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end
-- 检索过滤器s.filter：判定一张卡是否为‘1星仪式怪兽’或‘「食谱」卡’，且能够加入手卡；用于从卡组检索。
function s.filter(c)
	return (c:IsLevel(1) and c:IsType(TYPE_RITUAL) or c:IsSetCard(0x197)) and c:IsAbleToHand()
end
-- 墓地过滤器s.mfilter：判定一张卡是否属于「食谱」且可以被除外；用于选择从墓地除外的卡。
function s.mfilter(c)
	return c:IsSetCard(0x197) and c:IsAbleToRemove()
end
-- 辅助检定函数s.chk：用于判断所选的墓地「食谱」卡组g，是否能在手牌中找到对应等级且可特殊召唤的‘新式魔厨’仪式怪兽。
function s.chk(g,e,tp)
	-- 检查手牌中是否存在至少1只等级等于已选「食谱」卡数量（#g）的‘新式魔厨’仪式怪兽，且可被特殊召唤。
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND,0,1,nil,e,tp,#g)
end
-- 手牌特召过滤器s.sfilter：判定手牌中的卡是否为‘新式魔厨’仪式怪兽，等级等于指定值ct，并且可被效果特殊召唤（不检查苏生限制）。
function s.sfilter(c,e,tp,ct)
	return c:IsSetCard(0x196) and c:IsType(TYPE_RITUAL) and c:IsLevel(ct) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 怪兽效果①的目标（选项）选择：分别检查两个选项是否可用——选项1（卡组检索）、选项2（墓地除外+手卡特召）；然后让玩家选择，并根据选择动态设置效果分类、处理函数和操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查选项1是否可用：卡组中是否存在至少1张满足s.filter的卡（1星仪式怪兽或「食谱」卡，且可加入手卡）。
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	-- 获取墓地中所有属于「食谱」且可除外的卡组成卡组g，用于选项2的候选。
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查选项2是否可用：自己场上有可用怪兽区，并且墓地中存在一组（1~99张）「食谱」卡，对应手牌中有可特殊召唤的‘新式魔厨’仪式怪兽（通过CheckSubGroup调用s.chk验证）。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.chk,1,99,e,tp)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)})  --"从卡组加入手卡/从手卡特殊召唤"
	if op==1 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e:SetOperation(s.search)
		-- 设置操作信息（选项1）：本次效果将要把卡组中的1张卡加入手卡（目标不确定，故targets为nil，位置为卡组）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.psrsum)
		-- 设置操作信息（选项2）：本次效果将把墓地中的「食谱」卡g作为可能除外的对象，预计除外数量为1张以上。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		-- 设置操作信息（选项2）：本次效果将把1只怪兽从手卡特殊召唤（具体目标不确定，故targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
-- 选项1的处理：从卡组选择1张满足s.filter的卡加入手卡，并向对方公开确认。
function s.search(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示“请选择要加入手牌的卡”，用于检索选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足s.filter的卡（1星仪式怪兽或「食谱」卡，可加入手卡）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选出的卡以效果原因加入其持有者的手卡（这里为卡组所有者自己的手卡）。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方玩家展示加入手卡的卡，确认检索内容（对方确认）。
	Duel.ConfirmCards(1-tp,g)
end
-- 选项2的处理：先确认有怪兽区空位；从墓地选择1~99张「食谱」卡除外（需保证手牌有对应等级的可特召‘新式魔厨’仪式怪兽）；再按实际除外数量从手牌选择1只对应等级的仪式怪兽特殊召唤。
function s.psrsum(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己场上是否有可用怪兽区，若没有则直接结束处理（无法特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取墓地中所有可除外且属于「食谱」的卡组，用于选择除外对象。
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	-- 发送选择提示“请选择要除外的卡”，用于墓地除外的选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=g:SelectSubGroup(tp,s.chk,false,1,99,e,tp)
	if not mg then return end
	-- 将选中的「食谱」卡组以表侧表示除外，返回实际除外的数量ct；该数量决定可特召的仪式怪兽等级。
	local ct=Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	-- 发送选择提示“请选择要特殊召唤的卡”，用于手牌特殊召唤的选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足s.sfilter的‘新式魔厨’仪式怪兽，其等级必须等于实际除外的「食谱」卡数量ct，且可被特殊召唤。
	local sg=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,ct)
	-- 将选择的仪式怪兽以表侧表示特殊召唤到自己场上（不检查苏生限制，但检查特殊召唤条件）。
	Duel.SpecialSummon(sg,0,tp,tp,false,true,POS_FACEUP)
end
