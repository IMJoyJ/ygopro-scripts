--オメガの裁き
-- 效果：
-- ①：以自己的魔法与陷阱区域1张表侧表示的怪兽卡和对方场上2张卡为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 创建并注册该卡的效果：设置破坏分类、魔法卡发动类型、自由发动时点、取对象属性、提示时点、目标选择函数与处理函数，使这张卡获得①效果的发动能力。
function s.initial_effect(c)
	-- ①：以自己的魔法与陷阱区域1张表侧表示的怪兽卡和对方场上2张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 筛选条件：处于己方魔法与陷阱区域（后场，不含场地格）的表侧表示怪兽卡（原本种类含怪兽类型）。
function s.filter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetSequence()<5
end
-- 目标函数前半部分：先排除以特定卡为对象的处理；在发动条件检查时，确认场上存在满足条件的目标——己方魔法与陷阱区域有1张表侧表示怪兽卡，且对方场上存在2张卡可作为对象。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查己方魔法与陷阱区域是否存在至少1张满足s.filter条件的表侧表示怪兽卡，以满足该效果的取对象前提。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil)
		-- 检查对方场上是否存在至少2张能够成为对象的卡，以满足“对方场上2张卡为对象”的发动条件。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示，用于下一步选择目标时的界面引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方魔法与陷阱区域中1张表侧表示的怪兽卡作为对象，并设置为该连锁的对象（对应“以自己的魔法与陷阱区域1张表侧表示的怪兽卡”）。
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 再次向操作玩家显示“请选择要破坏的卡”的选择提示，用于选择对方场上的2张卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上2张卡作为对象，并设置为该连锁的对象（对应“对方场上2张卡”）。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,2,2,nil)
	g1:Merge(g2)
	-- 将合并后的对象组（己方1张怪兽卡+对方2张卡）的操作信息写入连锁，声明这些卡将被破坏，数量为对象总数，供后续效果联动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
-- 效果处理函数：从连锁信息中取出对象并过滤出仍与效果关联的卡，然后将它们破坏；对应“那些卡破坏。”。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象组，并过滤掉已不与该效果关联的卡（如离场或失去联系），仅保留可正常处理的对象。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的目标卡以效果原因（REASON_EFFECT）全部破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
