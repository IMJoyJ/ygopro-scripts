--三戦の号
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这个回合对方是已把怪兽的效果发动的场合才能发动。从卡组把「三战之号」以外的1张通常魔法·通常陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。对方场上有怪兽存在的场合，也能不盖放加入手卡。
local s,id,o=GetID()
-- s.initial_effect：创建并注册『三战之号』的①效果，同时注册自定义活动计数器，用于记录本回合发动过怪兽效果的情况，以供发动条件判定。
function s.initial_effect(c)
	-- 对应效果原文：①：这个回合对方是已把怪兽的效果发动的场合才能发动。从卡组把「三战之号」以外的1张通常魔法·通常陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。对方场上有怪兽存在的场合，也能不盖放加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册自定义活动计数器：当玩家发动效果且该效果的类型不是怪兽效果时计数器增加；因为过滤器返回false的情况（即发动怪兽效果）才会计数，所以该计数器用于检测“发动过怪兽效果”的次数。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FilterBoolFunction(aux.NOT(Effect.IsActiveType),TYPE_MONSTER))
end
-- s.condition：效果发动条件判定，检查对方（1-tp）本回合是否已发动过怪兽效果（自定义计数器次数不为0），满足“这个回合对方是已把怪兽的效果发动的场合才能发动”。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方本回合发动怪兽效果的次数，若不为0则满足①效果的发动条件。
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0
end
-- s.filter：筛选卡组中符合条件的卡：必须是通常魔法或通常陷阱卡、卡名不为「三战之号」，并且结合b1（自己魔陷区有空位可盖放）和b2（对方场上有怪兽可加入手卡）进行条件判断。
function s.filter(c,b1,b2)
	return (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP) and not c:IsCode(id)
		and (b1 and c:IsSSetable() or b2 and c:IsAbleToHand())
end
-- s.target：效果发动时的目标选择处理：计算魔陷区空位，判断能否盖放；判断对方场上是否有怪兽决定能否加入手卡；并检查卡组是否存在符合条件的卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己魔陷区的可用空格数量，用于判断是否满足“从卡组把卡在自己场上盖放”的条件。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	local b1=ct>0
	-- 判断对方场上是否存在怪兽，作为“对方场上有怪兽存在的场合，也能不盖放加入手卡”的判定条件。
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	-- 在效果发动时（chk==0）检查卡组中是否存在至少1张满足s.filter且符合当前盖放/加入手卡条件的卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,b1,b2) end
end
-- s.activate：效果处理时的具体操作：判断对方场上是否有怪兽，从卡组选择1张符合条件的通常魔法·通常陷阱卡，再根据玩家选择和卡片状态决定盖放（并附加本回合不能发动效果的限制）或加入手卡并让对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 记录对方场上是否有怪兽存在，用于后续分支中判断是否允许选择“加入手卡”的线路。
	local th=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	-- 向玩家显示“请选择要操作的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张符合条件的通常魔法·通常陷阱卡；传入true和th分别作为s.filter的b1和b2参数，表示“有魔陷区空位”和“对方场上有怪兽”。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,true,th):GetFirst()
	if not tc then return end
	local b1=tc:IsSSetable()
	local b2=th and tc:IsAbleToHand()
	-- 如果所选卡可以盖放，并且（该卡不能加入手卡或玩家选择了盖放选项）则执行盖放；否则若可加入手卡则执行加入手卡。
	if b1 and (not b2 or Duel.SelectOption(tp,1153,1190)==0) then
		-- 将选中的卡在自己场上以里侧表示盖放。
		Duel.SSet(tp,tc)
		-- 对应效果原文：这个效果盖放的卡在这个回合不能发动。对方场上有怪兽存在的场合，也能不盖放加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	elseif b2 then
		-- 将选中的卡加入手卡，实现“也能不盖放加入手卡”的效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，使其确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
