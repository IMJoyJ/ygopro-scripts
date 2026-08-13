--The despair URANUS
-- 效果：
-- ①：自己场上没有魔法·陷阱卡存在，这张卡上级召唤成功时才能发动。对方宣言卡的种类（永续魔法·永续陷阱）。自己从卡组选宣言的种类的1张卡在自己的魔法与陷阱区域盖放。
-- ②：这张卡的攻击力上升自己场上的表侧表示的魔法·陷阱卡数量×300。
-- ③：只要这张卡在怪兽区域存在，自己的魔法与陷阱区域的表侧表示的卡不会被效果破坏。
function c32588805.initial_effect(c)
	-- ①：自己场上没有魔法·陷阱卡存在，这张卡上级召唤成功时才能发动。对方宣言卡的种类（永续魔法·永续陷阱）。自己从卡组选宣言的种类的1张卡在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32588805,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c32588805.setcon)
	e1:SetTarget(c32588805.settg)
	e1:SetOperation(c32588805.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升自己场上的表侧表示的魔法·陷阱卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c32588805.atkval)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己的魔法与陷阱区域的表侧表示的卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(c32588805.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判断①效果能否发动的条件：这张卡是否以表侧上级召唤方式成功召唤成功，且我方场上不存在魔法·陷阱卡（需同时满足）。
function c32588805.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
		-- 条件后半部分：我方场上（己方区域）不存在任何魔法·陷阱卡（包含表侧和里侧）。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 定义检索永续魔法/陷阱的备用过滤器：用于确认卡组中是否存在可盖放到魔陷区的永续类型卡（包含魔法或陷阱），以便作为①效果的对象。
function c32588805.setfilter1(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
-- ①效果的发动目标判定：若在发动时确认我方魔陷区有空位且卡组中存在至少1张符合条件的永续卡，则允许发动。
function c32588805.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方魔法与陷阱区域是否有可用的空格（若有返回true，否则false）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少1张满足setfilter1（即永续魔法/陷阱且可盖放）的卡。
		and Duel.IsExistingMatchingCard(c32588805.setfilter1,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义按宣言种类精确匹配的过滤器：卡的完整类型（魔法/陷阱+永续）与宣言的typ一致，且该卡可以被盖放到魔陷区。
function c32588805.setfilter2(c,typ)
	return c:GetType()==typ and c:IsSSetable()
end
-- ①效果的结算处理：先由对方宣言永续魔法或永续陷阱，然后我方从卡组选择宣言种类的1张卡，将其盖放到我方魔法与陷阱区域。
function c32588805.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认魔陷区仍有空位；若无空位则整个效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向对方（1-tp）发送选择提示，弹出“请选择一个选项”的消息，用于之后让对方宣言种类。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
	-- 由对方选择宣言的种类：71对应永续魔法，72对应永续陷阱，返回选择结果op（0或1）。
	local op=Duel.SelectOption(1-tp,71,72)
	-- 向自己（tp）发送选择提示，弹出“请选择要盖放的卡”的消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local g=nil
	-- 若对方宣言了永续魔法（op==0），则从自己的卡组选择1张永续魔法卡（类型为魔法+永续且可盖放）作为要盖放的卡。
	if op==0 then g=Duel.SelectMatchingCard(tp,c32588805.setfilter2,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
	-- 否则（op==1）表示对方宣言永续陷阱，从卡组选择1张永续陷阱卡（类型为陷阱+永续且可盖放）作为要盖放的卡。
	else g=Duel.SelectMatchingCard(tp,c32588805.setfilter2,tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP+TYPE_CONTINUOUS) end
	if g:GetCount()>0 then
		-- 将玩家选择出的那张卡以里侧表示放置到自己的魔法与陷阱区域（完成盖放操作）。
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 定义统计自己场上表侧表示的魔法·陷阱卡的过滤器：卡的类型为魔法或陷阱且为表侧表示。
function c32588805.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- 定义②效果的攻击力变化值计算：统计自己场上表侧的魔法·陷阱卡数量，每张使攻击力上升300。
function c32588805.atkval(e,c)
	-- 返回自己场上表侧魔法陷阱卡数量×300，作为此卡的攻击力上升值。
	return Duel.GetMatchingGroupCount(c32588805.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*300
end
-- 定义③效果的受保护对象判定：只保护位于通常魔法与陷阱区域（序号<5，不包括场地格）且表侧表示的卡不被效果破坏。
function c32588805.indtg(e,c)
	return c:GetSequence()<5 and c:IsFaceup()
end
