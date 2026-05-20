--軍貫処 『海せん』
-- 效果：
-- ①：1回合1次，自己对「军贯」怪兽的召唤·特殊召唤成功的场合才能发动（伤害步骤也能发动）。从卡组选1张「军贯」卡在卡组最上面放置。
-- ②：1回合1次，从额外卡组特殊召唤的自己场上的「军贯」怪兽被对方送去墓地的场合发动。对方支付那个守备力数值的基本分。那之后，自己可以让以下效果适用。
-- ●手卡1只「舍利军贯」特殊召唤，把1只「军贯」超量怪兽在那上面重叠当作超量召唤从额外卡组特殊召唤。
function c62200831.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己对「军贯」怪兽的召唤·特殊召唤成功的场合才能发动（伤害步骤也能发动）。从卡组选1张「军贯」卡在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62200831,0))  --"从卡组选1张「军贯」卡在卡组最上面放置"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c62200831.dtcon)
	e2:SetTarget(c62200831.dttg)
	e2:SetOperation(c62200831.dtop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：1回合1次，从额外卡组特殊召唤的自己场上的「军贯」怪兽被对方送去墓地的场合发动。对方支付那个守备力数值的基本分。那之后，自己可以让以下效果适用。●手卡1只「舍利军贯」特殊召唤，把1只「军贯」超量怪兽在那上面重叠当作超量召唤从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62200831,2))  --"对方支付基本分"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c62200831.spcon)
	e4:SetTarget(c62200831.sptg)
	e4:SetOperation(c62200831.spop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己召唤·特殊召唤成功的表侧表示「军贯」怪兽
function c62200831.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x166) and c:IsSummonPlayer(tp)
end
-- 效果①的发动条件：自己对「军贯」怪兽的召唤·特殊召唤成功
function c62200831.dtcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62200831.cfilter,1,nil,tp)
end
-- 效果①的靶向与可行性检查：检查卡组是否有至少2张卡，且卡组中存在「军贯」卡
function c62200831.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡片数量是否大于1张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		-- 检查自己卡组中是否存在至少1张「军贯」卡
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x166) end
end
-- 效果①的效果处理：从卡组选1张「军贯」卡，洗切卡组后放置在卡组最上面，并进行确认
function c62200831.dtop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要在卡组最上面放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62200831,1))  --"请选择要在卡组最上面放置的卡"
	-- 让玩家从卡组选择1张「军贯」卡
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x166)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认自己卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 过滤条件：从额外卡组特殊召唤的、原本由自己控制的表侧表示「军贯」怪兽，因对方原因被送去墓地
function c62200831.cfilter2(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousSetCard(0x166) and c:GetReasonPlayer()==1-tp
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果②的发动条件：从额外卡组特殊召唤的自己场上的「军贯」怪兽被对方送去墓地
function c62200831.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62200831.cfilter2,1,nil,tp)
end
-- 效果②的靶向与可行性检查：此效果为必发效果，直接返回true，并在发动时计算被送去墓地的符合条件怪兽的原本守备力合计值并记录
function c62200831.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tg=eg:Filter(c62200831.cfilter2,nil,tp)
	local def=tg:GetSum(Card.GetBaseDefense)
	e:SetLabel(def)
end
-- 过滤条件：手卡中可以特殊召唤的「舍利军贯」，且额外卡组存在可以以其为素材进行超量召唤的「军贯」超量怪兽
function c62200831.spfilter(c,e,tp)
	return c:IsCode(24639891) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在满足条件的「军贯」超量怪兽
		and Duel.IsExistingMatchingCard(c62200831.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤条件：额外卡组的「军贯」超量怪兽，能以指定的「舍利军贯」为超量素材进行特殊召唤，且额外怪兽区域有可用位置
function c62200831.xyzfilter(c,e,tp,mc)
	return c:IsSetCard(0x166) and mc:IsCanBeXyzMaterial(c) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查在将素材怪兽作为素材时，额外卡组怪兽是否有可用的特殊召唤区域
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的效果处理：对方支付对应数值的基本分，之后可以从手卡特殊召唤「舍利军贯」，并在其上重叠超量召唤「军贯」超量怪兽
function c62200831.spop(e,tp,eg,ep,ev,re,r,rp)
	local def=e:GetLabel()
	-- 如果守备力合计值为0，或者大于对方当前生命值，则不处理后续效果
	if def==0 or def>Duel.GetLP(1-tp) then return end
	-- 对方支付等同于该守备力数值的基本分
	Duel.PayLPCost(1-tp,def)
	-- 检查自己是否能进行2次特殊召唤
	if Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在必须作为超量素材的卡片限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查手卡中是否存在满足特殊召唤条件的「舍利军贯」及对应的额外卡组「军贯」超量怪兽
		and Duel.IsExistingMatchingCard(c62200831.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否选择适用后续的特殊召唤效果
		and Duel.SelectYesNo(tp,aux.Stringid(62200831,3)) then  --"是否特殊召唤？"
		-- 中断当前效果，使后续的特殊召唤处理与支付基本分不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要作为超量素材的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 玩家从手卡选择1只用于特殊召唤的「舍利军贯」
		local g1=Duel.SelectMatchingCard(tp,c62200831.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的「舍利军贯」在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		-- 提示玩家选择要特殊召唤的额外卡组怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足条件的「军贯」超量怪兽
		local g2=Duel.SelectMatchingCard(tp,c62200831.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g1:GetFirst())
		local tc=g2:GetFirst()
		tc:SetMaterial(g1)
		-- 将特殊召唤的「舍利军贯」作为超量素材重叠在选中的超量怪兽下
		Duel.Overlay(tc,g1)
		-- 将该「军贯」超量怪兽当作超量召唤从额外卡组表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
