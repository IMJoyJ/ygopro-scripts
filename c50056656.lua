--スカーレッド・ゾーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在，对方把卡的效果发动时，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：以自己的除外状态的1只龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：给「真红莲区域」注册魔法卡发动所需的空效果（EFFECT_TYPE_ACTIVATE+EVENT_FREE_CHAIN），并注册①的破坏效果e2和②的特殊召唤效果e3；e2/e3分别设置描述、分类、类型、发动时机、生效区域、1回合1次限制、取对象标志、条件/目标/处理函数。
function s.initial_effect(c)
	-- 调用aux.AddCodeList，把卡号70902743「红莲魔龙」登记为本卡效果文本中记载的卡名，供后续aux.IsCodeListed判断“有那个卡名记述的同调怪兽”。
	aux.AddCodeList(c,70902743)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 整体有“这个卡名的①②的效果1回合各能使用1次”；此处对应①效果原文：“①：自己场上有着「红莲魔龙」或者有那个卡名记述的同调怪兽存在，对方把卡的效果发动时，以场上1张卡为对象才能发动。那张卡破坏。”本段创建并注册该诱发即时效果，并通过SetCountLimit(1,id)实现①的1回合1次限制。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"场上的卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- 整体有“这个卡名的①②的效果1回合各能使用1次”；此处对应②效果原文：“②：以自己的除外状态的1只龙族·暗属性同调怪兽为对象才能发动。那只怪兽特殊召唤。”本段创建并注册该诱发即时效果，并通过SetCountLimit(1,id+o)实现②的1回合1次限制。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外的怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数s.cfilter：判断场上怪兽是否满足①的发动条件——表侧表示，且是「红莲魔龙」（70902743），或者是位于主要怪兽区的同调怪兽且其卡名记述了「红莲魔龙」。
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(70902743) or c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_MZONE)
		-- 追加判定：该同调怪兽的卡名中确实记述有「红莲魔龙」。
		and aux.IsCodeListed(c,70902743))
end
-- 定义①效果的发动条件函数s.descon：只有当对方发动卡的效果（rp==1-tp）且自己场上有满足cfilter的怪兽时，本卡才能发动①效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回发动条件的具体判断：对方回合发动效果，且己方场上存在至少1只表侧表示的「红莲魔龙」或卡名记述该卡的同调怪兽。
	return rp==1-tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义①效果的目标选择函数s.destg：取对象时仅接受场上1张卡；发动合法性检查场上是否有对象；然后向对方提示发动，让己方从双方场上选择1张卡作为破坏对象，并登记破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断场上是否存在至少1张可以被选择为对象的卡（双方怪兽区/魔陷区皆可），若不存在则①效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家（1-tp）发送提示，展示己方正在发动的「真红莲区域」①效果，使对方明确发动内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 为当前玩家弹出选择提示，文案为“请选择要破坏的卡”，用于选择①效果要破坏的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家tp从双方场上（LOCATION_ONFIELD,LOCATION_ONFIELD）选择1张卡作为①效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁的破坏操作信息：分类为CATEGORY_DESTROY，对象为g中的1张卡，用于后续时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义①效果的处理函数s.desop：取得连锁对象，若对象仍与本连锁相关，则用效果将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果选择的第1张（也是唯一）对象卡，作为要破坏的卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与本连锁保持联系，若仍相关，则以REASON_EFFECT的原因将其破坏。
	if tc:IsRelateToChain() then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 定义②效果特殊召唤对象的过滤函数s.filter：对象须为表侧表示、暗属性、龙族、同调怪兽，且能被当前玩家tp通过本效果特殊召唤（正常检查召唤条件与苏生限制）。
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义②效果的目标选择函数s.sptg：取对象时只能选择自己除外区的1只符合条件的龙族暗属性同调怪兽；发动合法性需有怪兽区空位且存在目标；随后提示对方、让己方选择目标并登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有空位，若没有空位则②效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在至少1只满足s.filter条件的龙族暗属性同调怪兽可作为对象，否则不能发动。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向对方玩家（1-tp）发送提示，展示己方正在发动的「真红莲区域」②效果，使对方明确发动内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 为当前玩家弹出选择提示，文案为“请选择要特殊召唤的卡”，用于选择②效果要特殊召唤的除外怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家tp从自己除外区（LOCATION_REMOVED）选择1只满足s.filter条件的怪兽作为②效果对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记本次连锁的特殊召唤操作信息：分类为CATEGORY_SPECIAL_SUMMON，对象为g中的1张卡，用于后续时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义②效果的处理函数s.spop：取得连锁对象，若对象仍与效果相关，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的第1张（也是唯一）对象卡，作为要特殊召唤的除外怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与本效果保持联系，若相关，则将其以表侧表示（POS_FACEUP）特殊召唤到己方场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
