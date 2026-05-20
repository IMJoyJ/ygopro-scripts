--大樹海
-- 效果：
-- 场上表侧表示存在的昆虫族怪兽被战斗或者卡的效果破坏送去墓地时，那些怪兽的控制者可以把和破坏的怪兽相同等级的1只昆虫族怪兽从卡组加入手卡。
function c80402389.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的昆虫族怪兽被战斗或者卡的效果破坏送去墓地时，那些怪兽的控制者可以把和破坏的怪兽相同等级的1只昆虫族怪兽从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetDescription(aux.Stringid(80402389,0))  --"检索"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCode(EVENT_CUSTOM+80402389)
	e3:SetTarget(c80402389.target)
	e3:SetOperation(c80402389.operation)
	c:RegisterEffect(e3)
	if not c80402389.global_check then
		c80402389.global_check=true
		-- 场上表侧表示存在的昆虫族怪兽被战斗或者卡的效果破坏送去墓地时，那些怪兽的控制者可以把和破坏的怪兽相同等级的1只昆虫族怪兽从卡组加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c80402389.check)
		-- 注册全局环境的永续效果，用于监听卡片送去墓地的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局监听函数，遍历所有送去墓地的卡，筛选出原本在场上表侧表示存在、因破坏而送去墓地的等级1以上的昆虫族怪兽。
function c80402389.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_DESTROY)
			and tc:IsRace(RACE_INSECT) and tc:IsLevelAbove(1) and tc:IsPreviousPosition(POS_FACEUP) then
			-- 触发自定义事件，传入被破坏怪兽的控制者作为事件玩家，并将其等级作为参数传递。
			Duel.RaiseEvent(tc,EVENT_CUSTOM+80402389,re,r,rp,tc:GetControler(),tc:GetLevel())
		end
		tc=eg:GetNext()
	end
end
-- 过滤函数，用于筛选卡组中与被破坏怪兽等级相同且可以加入手牌的昆虫族怪兽。
function c80402389.filter(c,lv)
	return c:IsRace(RACE_INSECT) and c:IsLevel(lv) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与检测函数，确认卡组中存在符合条件的怪兽，并设置检索的操作信息。
function c80402389.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1只与被破坏怪兽等级相同（由参数ev传入）且可加入手牌的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c80402389.filter,tp,LOCATION_DECK,0,1,nil,ev) end
	-- 设置当前连锁的操作信息，表明此效果包含从卡组将1张卡加入手牌的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，让玩家从卡组选择1只符合条件的昆虫族怪兽加入手牌并给对方确认。
function c80402389.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家发送系统提示，要求其选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动效果的玩家从卡组中选择1只与被破坏怪兽等级相同（由参数ev传入）的昆虫族怪兽。
	local g=Duel.SelectMatchingCard(tp,c80402389.filter,tp,LOCATION_DECK,0,1,1,nil,ev)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
