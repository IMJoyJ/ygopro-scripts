--神芸獄徒 ディアクトロス
-- 效果：
-- 「无垢者 米底乌斯」＋「神艺」怪兽
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：自己场上的怪兽的种族是3种类以上，对方把魔法·陷阱·怪兽的效果在场上发动时才能发动。那个发动无效并破坏。
-- ③：融合召唤的这张卡被破坏的场合才能发动。自己的手卡·卡组·除外状态的1只「无垢者 米底乌斯」特殊召唤。
local s,id,o=GetID()
-- 初始化这张卡的脚本：启用融合召唤复活限制，添加融合召唤手续，并分别注册①改变表示形式的起动效果、②无效并破坏的诱发即时效果、③被破坏后特殊召唤「无垢者 米底乌斯」的诱发效果；三个效果各自用不同code设置1回合只能使用1次。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材为1只「无垢者 米底乌斯」（卡号97556336）＋1只「神艺」怪兽。
	aux.AddFusionProcCodeFun(c,97556336,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1cd),1,true,true)
	-- ①：以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- ②：自己场上的怪兽的种族是3种类以上，对方把魔法·陷阱·怪兽的效果在场上发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被破坏的场合才能发动。自己的手卡·卡组·除外状态的1只「无垢者 米底乌斯」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义目标过滤函数：判断怪兽是否可以进行表示形式变更（排除不能变更表示形式的怪兽）。
function s.posfilter(c)
	return c:IsCanChangePosition()
end
-- 效果①的发动条件与选对象函数：发动前检查场上是否存在可变更表示形式的怪兽，若存在则让玩家选择双方场上1只这样的怪兽作为对象，并设置表示形式变更的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	-- 发动前检查：双方场上是否至少存在1只满足变更表示形式条件的怪兽，作为效果①能否发动的合法性判定。
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，要求选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方场上选择1只可以变更表示形式的怪兽，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本效果类别为变更表示形式（CATEGORY_POSITION），目标为所选的1张怪兽卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的处理函数：取得对象怪兽，若其仍与效果相关，则将它的表示形式切换为与当前相反的形式（表侧攻击表示与表侧守备表示互换）。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果①发动时选择的唯一目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标怪兽的表示形式改变：表侧攻击表示变为表侧守备表示，表侧守备表示变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 效果②的发动条件判断：对方在场上发动魔法·陷阱·怪兽效果，且自己场上有3种以上不同种族的表侧表示怪兽，本卡未被战斗破坏，且对方发动的连锁可以被无效时才能发动。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中对方发动的效果所在位置及发动玩家，用于判断是否满足“对方在场上发动效果”的条件。
	local loc,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_PLAYER)
	-- 取得自己场上全部表侧表示怪兽，用于统计不同种族的种类数量。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return p==1-tp and bit.band(loc,LOCATION_ONFIELD)~=0 and g:GetClassCount(Card.GetRace)>2
		-- 追加判断：本卡没有处于战斗破坏状态（避免伤害步骤被战破时误发动），且对方发动的那个连锁可以被无效。
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果②的发动目标与操作信息设置：该效果无需额外取对象；设置无效对方发动的操作信息，并视情况追加破坏对方效果发动卡的操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将无效对方效果的发动（CATEGORY_NEGATE），对象为对方发动的效果事件组。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		-- 若对方效果发动卡能够被破坏且仍与该连锁相关，则追加设置破坏（CATEGORY_DESTROY）的操作信息，对象为该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的处理函数：尝试无效对方连锁的发动；若无效成功且对方效果发动卡仍与连锁相关，则将其破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使对方连锁的发动无效；如果无效成功，并确认对方效果发动卡仍与该连锁相关，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 以效果原因（REASON_EFFECT）破坏对方发动效果的那张卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡是被融合召唤的怪兽，且在被破坏前位于怪兽区域；满足该条件时才可发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果③的发动合法性检查：自己场上存在可用的怪兽区域空位，且手卡·卡组·除外状态存在1只可以特殊召唤的「无垢者 米底乌斯」。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有至少1个可用的主要怪兽区域空位，用于特殊召唤「无垢者 米底乌斯」。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·卡组·除外状态是否存在至少1只「无垢者 米底乌斯」，且它能够被当前效果特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本效果类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），预定从手卡·卡组·除外状态特殊召唤1只卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED)
end
-- 特殊召唤对象的过滤条件：该卡必须是「无垢者 米底乌斯」（卡号97556336），并且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(97556336) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的处理函数：若场上仍有空位，则让玩家从手卡·卡组·除外状态选择1只「无垢者 米底乌斯」，并以表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查场上怪兽区域空位；若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的「无垢者 米底乌斯」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·除外状态选择1只符合条件的「无垢者 米底乌斯」。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「无垢者 米底乌斯」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
