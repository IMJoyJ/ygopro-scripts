--渇きの風
-- 效果：
-- 「干渴之风」的①②的效果1回合各能使用1次。
-- ①：自己基本分回复的场合，以对方场上1只表侧表示怪兽为对象把这个效果发动。那只怪兽破坏。
-- ②：自己场上有「芳香」怪兽存在，自己基本分比对方多3000以上的场合，支付那个相差数值的基本分才能把这个效果发动。攻击力合计最多到为这个效果发动而支付的基本分数值以下为止，选对方场上的表侧表示怪兽破坏。
function c28265983.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己基本分回复的场合，以对方场上1只表侧表示怪兽为对象把这个效果发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28265983,1))  --"选择1只怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_RECOVER)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,28265983)
	e1:SetCondition(c28265983.descon1)
	e1:SetTarget(c28265983.destg1)
	e1:SetOperation(c28265983.desop1)
	c:RegisterEffect(e1)
	-- ②：自己场上有「芳香」怪兽存在，自己基本分比对方多3000以上的场合，支付那个相差数值的基本分才能把这个效果发动。攻击力合计最多到为这个效果发动而支付的基本分数值以下为止，选对方场上的表侧表示怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28265983,2))  --"选攻击力在支付的基本分数值以下的怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,28265984)
	e3:SetCondition(c28265983.descon2)
	e3:SetCost(c28265983.descost2)
	e3:SetTarget(c28265983.destg2)
	e3:SetOperation(c28265983.desop2)
	c:RegisterEffect(e3)
end
-- 判断触发条件：本效果只在己方（效果控制者）回复基本分时才能发动（即回复者是己方）。
function c28265983.descon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 定义候选对象过滤器：必须是表侧表示怪兽。
function c28265983.desfilter1(c)
	return c:IsFaceup()
end
-- 效果的发动与目标选择：若检查已选对象则需满足在对方怪兽区且表侧表示；若为发动时判定则直接允许（必发效果）；随后提示玩家选择对方场上1只表侧表示怪兽作为对象，并登记破坏该对象的效果信息。
function c28265983.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c28265983.desfilter1(chkc) end
	if chk==0 then return true end
	-- 发出选择提示：请玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从对方场上选择1只表侧表示怪兽，将其指定为效果对象。
	local g=Duel.SelectTarget(tp,c28265983.desfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本次效果将破坏所选择的对象，数量为对象数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：取得效果对象，若对象仍与该效果关联，则将其破坏。
function c28265983.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这次效果发动时选择的对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将那只对象怪兽以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义「芳香」字段怪兽的过滤器：表侧表示且字段为「芳香」（0xc9）。
function c28265983.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- ②效果的发动条件：自己场上有表侧表示「芳香」怪兽存在，且自己当前LP比对方多3000以上。
function c28265983.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件判定：存在满足「芳香」字段的己方表侧怪兽，且LP差值不低于3000。
	return Duel.IsExistingMatchingCard(c28265983.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLP(tp)-Duel.GetLP(1-tp)>=3000
end
-- ②的代价函数：计算己方与对方LP的差值作为需要支付的LP；若处于代价检查阶段则确认能支付；支付该数值LP，并将支付数值存入效果Label供后续使用。
function c28265983.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算己方LP减去对方LP的差值，确定需要支付的基本分数值。
	local lp=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	-- 在代价检查阶段（chk==0）返回能否支付该LP差值。
	if chk==0 then return Duel.CheckLPCost(tp,lp,true) end
	-- 实际支付LP差值作为发动②效果的代价。
	Duel.PayLPCost(tp,lp,true)
	e:SetLabel(lp)
end
-- 定义②效果可破坏对象的过滤器：表侧表示且攻击力不高于指定数值num。
function c28265983.desfilter2(c,num)
	return c:IsFaceup() and c:IsAttackBelow(num)
end
-- ②的目标设定：计算当前LP差；若在发动判定阶段则检查是否存在至少1只攻击力不高于LP差的对方表侧怪兽；然后获取攻击力不高于已支付LP数值的对方怪兽组，并登记破坏其中怪兽的效果信息（不取对象，效果处理时选择具体数量）。
function c28265983.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算当前己方与对方的LP差，用于判断是否存在可选对象。
	local lp=Duel.GetLP(tp)-Duel.GetLP(1-tp)
	-- 检查对方场上是否存在至少1只攻击力不高于当前LP差的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28265983.desfilter2,tp,0,LOCATION_MZONE,1,nil,lp) end
	-- 获取对方场上所有攻击力不高于已支付LP数值（Label中存储）的表侧表示怪兽，作为可选破坏对象。
	local g=Duel.GetMatchingGroup(c28265983.desfilter2,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	-- 登记操作信息：本次效果为破坏效果，预计破坏1只（具体数量在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义子组选择条件：所选怪兽的攻击力合计不高于num（即支付的基本分数值）。
function c28265983.gselect(g,num)
	return g:GetSum(Card.GetAttack)<=num
end
-- ②效果处理：读取支付数值；获取对方场上所有攻击力不高于该数值的表侧怪兽；若没有则结束；提示玩家选择；让玩家从这些怪兽中选出攻击力合计不超过支付数值的任意数量；将选出的怪兽全部破坏。
function c28265983.desop2(e,tp,eg,ep,ev,re,r,rp)
	local num=e:GetLabel()
	-- 获取对方场上攻击力不高于支付数值的表侧表示怪兽组，作为本次可选破坏集合。
	local g=Duel.GetMatchingGroup(c28265983.desfilter2,tp,0,LOCATION_MZONE,nil,num)
	if g:GetCount()==0 then return end
	-- 发出选择提示：请玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:SelectSubGroup(tp,c28265983.gselect,false,1,#g,num)
	-- 将玩家选择出的怪兽组以效果原因全部破坏。
	Duel.Destroy(dg,REASON_EFFECT)
end
